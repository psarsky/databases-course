show dbs

use north0

db.customers.find()

show collections

db.categories.find();

db.orders.aggregate([

  // 1. Dołącz klienta
  {
    $lookup: {
      from: "customers",
      localField: "CustomerID",
      foreignField: "CustomerID",
      as: "Customer"
    }
  },
  { $unwind: "$Customer" },

  // 2. Dołącz pracownika
  {
    $lookup: {
      from: "employees",
      localField: "EmployeeID",
      foreignField: "EmployeeID",
      as: "Employee"
    }
  },
  { $unwind: "$Employee" },

  // 3. Dołącz pozycje zamówienia
  {
    $lookup: {
      from: "orderdetails",
      localField: "OrderID",
      foreignField: "OrderID",
      as: "Orderdetails"
    }
  },

  // 4. Wzbogacenie Orderdetails o informacje o produkcie i kategorię + wartość pozycji
  {
    $set: {
      Orderdetails: {
        $map: {
          input: "$Orderdetails",
          as: "od",
          in: {
            $mergeObjects: [
              "$$od",
              {
                product: {
                  $let: {
                    vars: {
                      prod: {
                        $arrayElemAt: [
                          {
                            $filter: {
                              input: "$$ROOT.products",
                              as: "p",
                              cond: { $eq: ["$$p.ProductID", "$$od.ProductID"] }
                            }
                          },
                          0
                        ]
                      }
                    },
                    in: {
                      ProductID: "$$prod.ProductID",
                      ProductName: "$$prod.ProductName",
                      QuantityPerUnit: "$$prod.QuantityPerUnit",
                      CategoryID: "$$prod.CategoryID",
                      CategoryName: {
                        $let: {
                          vars: {
                            cat: {
                              $arrayElemAt: [
                                {
                                  $filter: {
                                    input: "$$ROOT.categories",
                                    as: "c",
                                    cond: { $eq: ["$$c.CategoryID", "$$prod.CategoryID"] }
                                  }
                                },
                                0
                              ]
                            }
                          },
                          in: "$$cat.CategoryName"
                        }
                      }
                    }
                  }
                },
                Value: {
                  $multiply: [
                    "$$od.UnitPrice",
                    "$$od.Quantity",
                    { $subtract: [1, "$$od.Discount"] }
                  ]
                }
              }
            ]
          }
        }
      }
    }
  },

  // 5. Oblicz OrderTotal (suma wartości pozycji)
  {
    $set: {
      OrderTotal: {
        $sum: {
          $map: {
            input: "$Orderdetails",
            as: "item",
            in: "$$item.Value"
          }
        }
      }
    }
  },

  // 6. Dołącz Shippera
  {
    $lookup: {
      from: "shippers",
      localField: "ShipVia",
      foreignField: "ShipperID",
      as: "Shipper"
    }
  },
  { $unwind: "$Shipper" },

  // 7. Projekt końcowy (ładna struktura)
    {
  $project: {

    _id: 1,
    OrderID: 1,

    Customer: {
      CustomerID: "$Customer.CustomerID",
      CompanyName: "$Customer.CompanyName",
      City: "$Customer.City",
      Country: "$Customer.Country"
    },

    Employee: {
      EmployeeID: "$Employee.EmployeeID",
      FirstName: "$Employee.FirstName",
      LastName: "$Employee.LastName",
      Title: "$Employee.Title"
    },

    Dates: {
      OrderDate: "$OrderDate",
      RequiredDate: "$RequiredDate"
    },

    Orderdetails: {
      $map: {
        input: "$Orderdetails",
        as: "od",
        in: {
          UnitPrice: "$$od.UnitPrice",
          Quantity: "$$od.Quantity",
          Discount: "$$od.Discount",
          Value: "$$od.Value",
          product: {
            ProductID: "$$od.product.ProductID",
            ProductName: "$$od.product.ProductName",
            QuantityPerUnit: "$$od.product.QuantityPerUnit",
            CategoryID: "$$od.product.CategoryID",
            CategoryName: "$$od.product.CategoryName"
          }
        }
      }
    },

    Freight: 1,
    OrderTotal: 1,

    Shipment: {
      Shipper: {
        ShipperID: "$Shipper.ShipperID",
        CompanyName: "$Shipper.CompanyName"
      },
      ShipName: "$ShipName",
      ShipAddress: "$ShipAddress",
      ShipCity: "$ShipCity",
      ShipCountry: "$ShipCountry"
    }
  }
},
{ $out: "OrdersInfo" }
])
