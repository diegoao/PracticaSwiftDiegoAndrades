import Cocoa

// Práctica swift Diego Andrades Oñate

// MARK: Estructura de cliente
struct Client: Equatable {
    let name: String            // Nombre
    private let age: Int        // Edad
    private let height: Int  //Altura cm
    
    init(name: String, age: Int, height: Int) {
        self.name = name
        self.age = age
        self.height = height
    }
}

// MARK: Estructura de reservas
struct Reservation: Equatable {
    let id : Int
    let nameHotel: String
    let listClient: [Client]
    let day: Int
    let price: Float
    let breakfast: Bool
}
// MARK: Enum gestión de errores
enum ReservationError: Error {
    case duplicateId
    case reservationExistingCustomer
    case reservationNotFound
}

// MARK: Clase gestión de reservas hoteles
class HotelReservationManager{
    var reservas: [Reservation] = []
    var Counter:Int = 0
    var idlist: Set <Int> = []
    var clientlist: [Client] = []
    
    // Método para añadir reservas
    func reservationAdd(nameHotel: String, listClients: [Client], days:Int, price:Float, Breakfast: Bool)throws ->Reservation {
        //  Sumamos 1 cada vez que añadimos una reserva
        Counter += 1
        
        // Calculamos el precio de la reserva
        let priceReservation = calculatePrice(numberclient: listClients.count, days: days,price: price, breakfast: Breakfast)
        
        // Se crea una reserva
        let newReservation = (Reservation(id: Counter,nameHotel: nameHotel,listClient: listClients, day: days, price: priceReservation, breakfast: Breakfast))
        
        // Comprobamos si el id  de la reserva está repetido
        guard !idlist.contains(newReservation.id)  else {
            throw ReservationError.duplicateId
        }
        // Comprobamos si Cliente ya tiene una reserva
        guard !newReservation.listClient.contains(where:{clientlist.contains($0)})  else {
            throw ReservationError.reservationExistingCustomer
        }
        
        // Insertamos id en registro
        idlist.insert(newReservation.id)
        
        // Insertamos clientes en registro
        for client in newReservation.listClient{
            clientlist.append(client)
        }
        
        // Añadimos la reserva al listado
        reservas.append(newReservation)
        
     return newReservation
    }
}

// MARK: Extensión de clase HotelReservationManager
extension HotelReservationManager{
    // Método para calcular el precio
    func calculatePrice(numberclient: Int, days: Int, price: Float, breakfast:Bool)->Float{
        var food: Float = breakfast ? 1.25 : 1
        return (Float(numberclient * days)) * price * food
    }
    
    // Método para eliminar una reserva
    func eliminateReservation(id: Int) throws{
        guard idlist.contains(id) else {
            throw ReservationError.reservationNotFound
        }
        // Si la reserva existe la borramos
        reservas.removeAll{$0.id == id}
    }
    
    // Método que devuelve listado de reservas de forma ordenada
    func viewReservations(){
        if reservas.isEmpty{
            print("Listado de reservas vacío")
        }else{
            print("Listado de reservas:")
            for reservation in reservas{
                let namesClients: [String] = reservation.listClient.map{$0.name}
                let clientsFinal = namesClients.count > 1 ? namesClients.joined(separator: " y ") : namesClients.first ?? ""
                let breakfast: String = reservation.breakfast ? "con desayuno":"sin desayuno"
                let day: String = reservation.day > 1 ? "días":"dia"
                print("-Id \(reservation.id) a nombre de \(clientsFinal) de \(reservation.day) \(day) de duración en el hotel '\(reservation.nameHotel)' \(breakfast) por un importe de \(reservation.price)€")
            }
        }
    }
}
    
// MARK: Declaro lista de Clientes
let cliente1 = Client(name: "Goku", age: 30, height: 175)
let cliente2 = Client(name: "Piccolo", age: 29, height: 236)
let cliente3 = Client(name: "Krilin", age: 32, height: 153)
let cliente4 = Client(name: "Gohan", age: 32, height: 176)
let cliente5 = Client(name: "Vegeta", age: 32, height: 164)

// MARK: Creo instancia de la clase HotelReservationManager
var gestHotel = HotelReservationManager()

do{
    try gestHotel.reservationAdd(nameHotel: "PLAYA", listClients:[cliente1,cliente5], days:2, price:15, Breakfast: true)
    try  gestHotel.reservationAdd(nameHotel: "Martos", listClients: [cliente2], days: 1, price: 20, Breakfast: false)
    try  gestHotel.reservationAdd(nameHotel: "Caleta", listClients: [cliente3], days: 1, price: 22.5, Breakfast: true)
    try  gestHotel.reservationAdd(nameHotel: "Chelmon", listClients: [cliente4], days: 1, price: 22.5, Breakfast: true)
    try gestHotel.eliminateReservation(id: 3)

}catch ReservationError.duplicateId{
    print("Id de la reserva repetido")
}catch ReservationError.reservationExistingCustomer{
    print("Este cliente ya tiene una reserva en el hotel")
}catch ReservationError.reservationNotFound{
    print("No se encontró ninguna reserva con el id indicado para eliminar")
}

// MARK: Llamada a función para mostrar lista de reservas
gestHotel.viewReservations()



// MARK: GESTIÓN DE ERRORES /////////

// MARK: verifica errores al añadir reservas duplicadas (por ID o si otro
//cliente ya está en alguna otra reserva) y que nuevas reservas sean añadidas
//correctamente.
func testAddReservation(){
    var gestHoteltest1 = HotelReservationManager()

    do{
         let reservation1 = try gestHoteltest1.reservationAdd(nameHotel: "PLAYA", listClients:[cliente5], days:2, price:15, Breakfast: true)
        // Descomentar para borrar todas las reservas y probar como se muestra el error
        //gestHoteltest1.reservas.removeAll()
        assert(gestHoteltest1.reservas.contains{$0 == reservation1}, "No se ha realizado reserva correctamente")
        
        
        try gestHoteltest1.reservationAdd(nameHotel: "PLAYA", listClients:[cliente1], days:2, price:15, Breakfast: true)
        // Probar error dos reservas con clientes "REPETIDOS"
        try  gestHoteltest1.reservationAdd(nameHotel: "Martos", listClients: [cliente1], days: 1, price: 20, Breakfast: false)
        
        // Probar error dos reservas con "ID" repetidos
        try gestHoteltest1.reservationAdd(nameHotel: "PLAYA", listClients:[cliente2], days:2, price:15, Breakfast: true)
        // Asigno 0 para que el contador le asigne el mismo id a ambos y probar error de ID repetido
         gestHoteltest1.Counter = 0
        try  gestHoteltest1.reservationAdd(nameHotel: "Martos", listClients: [cliente3], days: 1, price: 20, Breakfast: false)

    }catch ReservationError.duplicateId{
        print("Id de la reserva repetido - TestAddReservation")
    }catch ReservationError.reservationExistingCustomer{
        print("Este cliente ya tiene una reserva en el hotel - TestAddReservation")
    }catch ReservationError.reservationNotFound{
        print("No se encontró ninguna reserva con el id indicado para eliminar - TestAddReservation")
    }catch{
        assertionFailure("Error está en otro sitio de la aplicación")
    }
}

// MARK: Test para verifica que las reservas se cancelen correctamente (borrándose del listado)
// y que cancelar una reserva no existente resulte en un error.
func testCancelReservation(){
    var gestHoteltest2 = HotelReservationManager()
    var reservation:Reservation

    do{
        reservation = try gestHoteltest2.reservationAdd(nameHotel: "PLAYA", listClients:[cliente1], days:2, price:40.25, Breakfast: true)
        
        // Elimino reserva creada para verificar en el assert que se ha borrado correctamente
        try gestHoteltest2.eliminateReservation(id:reservation.id)  // Si comentamos esta linea podemos verificar el error cuando no se borra una reserva correctamente
        assert(!gestHoteltest2.reservas.contains(reservation), "Error al intentar eliminar una reserva existente")
        
        // Intento borrar reserva no existente para verificar el error
        try gestHoteltest2.eliminateReservation(id: 30)

    }catch ReservationError.duplicateId{
        print("Id de la reserva repetido - testCancelReservation")
    }catch ReservationError.reservationExistingCustomer{
        print("Este cliente ya tiene una reserva en el hotel - testCancelReservation")
    }catch ReservationError.reservationNotFound{
        print("No se encontró ninguna reserva con el id indicado para eliminar - testCancelReservation")
    }catch{
        assertionFailure("Error está en otro sitio de la aplicación")
    }
}

// MARK: Test para asegurar que el sistema calcula los precios de forma consistente
func TestReservationPrice(){
    var gestHoteltest3 = HotelReservationManager()
    
    do{
        try gestHoteltest3.reservationAdd(nameHotel: "PLAYA", listClients:[cliente1], days:2, price:40.25, Breakfast: true)
        try gestHoteltest3.reservationAdd(nameHotel: "CASAJUAN", listClients: [cliente2], days: 2, price: 40.25, Breakfast: true)
       //try gestHoteltest3.reservationAdd(nameHotel: "CASAJUAN", listClients: [cliente2], days: 2, price: 40, Breakfast: true) // Para probar el error cáculo de precios

    }catch ReservationError.duplicateId{
        print("Id de la reserva repetido - TestReservationPrice")
    }catch ReservationError.reservationExistingCustomer{
        print("Este cliente ya tiene una reserva en el hotel - TestReservationPrice")
    }catch ReservationError.reservationNotFound{
        print("No se encontró ninguna reserva con el id indicado para eliminar - TestReservationPrice")
    }catch{
        assertionFailure("Error está en otro sitio de la aplicación")
    }
    // Genero un array con los precios de todas las  reservas
    let priceReservations = gestHoteltest3.reservas.map{$0.price}
    // Comparo los precios de las reservas para que sean iguales
    assert(priceReservations.allSatisfy { $0 == priceReservations.first }, "Error calculando los precios de la reserva, no son iguales")
}

// MARK: Gestión de errores
testAddReservation()
TestReservationPrice()
testCancelReservation()

