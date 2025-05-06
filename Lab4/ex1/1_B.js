show dbs

use north0

show collections

db.CustomerOrders.find()


db.OrdersInfo.aggregate([
  {
    $group: {
      _id: "$Customer.CustomerID",
      CompanyName: { $first: "$Customer.CompanyName" },
      City: { $first: "$Customer.City" },
      Country: { $first: "$Customer.Country" },
      Orders: {
        $push: {
          OrderID: "$OrderID",
          Employee: "$Employee",
          Dates: "$Dates",
          Orderdetails: "$Orderdetails",
          Freight: "$Freight",
          OrderTotal: "$OrderTotal",
          Shipment: "$Shipment"
        }
      }
    }
  },
  {
    $project: {
      _id: 0,
      CustomerID: "$_id",
      CompanyName: 1,
      City: 1,
      Country: 1,
      Orders: 1
    }
  },
  {
    $out: "CustomerOrders"  // <-- tutaj nowa kolekcja
  }
])




