// 1. Oryginalne kolekcje:
let maxOrderID = db.orders.find().sort({OrderID: -1}).limit(1).toArray()[0].OrderID;
let newOrderID = maxOrderID + 1;

db.orders.insertOne({
  OrderID: newOrderID,
  CustomerID: "ALFKI",
  EmployeeID: 5,
  OrderDate: new Date("2025-05-06"),
  RequiredDate: new Date("2025-05-15"),
  ShippedDate: null,
  ShipVia: 2,
  Freight: 25.50,
  ShipName: "Alfreds Futterkiste",
  ShipAddress: "Obere Str. 57",
  ShipCity: "Berlin",
  ShipRegion: null,
  ShipPostalCode: "12209",
  ShipCountry: "Germany"
});

db.orderdetails.insertMany([
  {
    OrderID: newOrderID,
    ProductID: 1,
    UnitPrice: 18.00,
    Quantity: 5,
    Discount: 0.0
  },
  {
    OrderID: newOrderID,
    ProductID: 10,
    UnitPrice: 31.00,
    Quantity: 3,
    Discount: 0.05
  }
]);


// 2. OrdersInfo:
let maxOrderID = db.OrdersInfo.find().sort({OrderID: -1}).limit(1).toArray()[0].OrderID;
let newOrderID = maxOrderID + 1;

let chaiProduct = db.products.findOne({ProductID: 1});
let ikuraProduct = db.products.findOne({ProductID: 10});
let chaiCategory = db.categories.findOne({CategoryID: chaiProduct.CategoryID});
let ikuraCategory = db.categories.findOne({CategoryID: ikuraProduct.CategoryID});

let customer = db.customers.findOne({CustomerID: "ALFKI"});
let employee = db.employees.findOne({EmployeeID: 5});
let shipper = db.shippers.findOne({ShipperID: 2});

let chaiValue = 18.00 * 5 * (1 - 0);
let ikuraValue = 31.00 * 3 * (1 - 0.05);
let orderTotal = chaiValue + ikuraValue;

db.OrdersInfo.insertOne({
  OrderID: newOrderID,
  Customer: {
    CustomerID: customer.CustomerID,
    CompanyName: customer.CompanyName,
    City: customer.City,
    Country: customer.Country
  },
  Employee: {
    EmployeeID: employee.EmployeeID,
    FirstName: employee.FirstName,
    LastName: employee.LastName,
    Title: employee.Title
  },
  Dates: {
    OrderDate: new Date("2025-05-06"),
    RequiredDate: new Date("2025-05-15"),
  },
  Orderdetails: [
    {
      UnitPrice: 18.00,
      Quantity: 5,
      Discount: 0,
      Value: 90.00,
      product: {
        ProductID: chaiProduct.ProductID,
        ProductName: chaiProduct.ProductName,
        QuantityPerUnit: chaiProduct.QuantityPerUnit,
        CategoryID: chaiProduct.CategoryID,
        CategoryName: chaiCategory.CategoryName
      }
    },
    {
      UnitPrice: 31.00,
      Quantity: 3,
      Discount: 0.05,
      Value: 88.35,
      product: {
        ProductID: ikuraProduct.ProductID,
        ProductName: ikuraProduct.ProductName,
        QuantityPerUnit: ikuraProduct.QuantityPerUnit,
        CategoryID: ikuraProduct.CategoryID,
        CategoryName: ikuraCategory.CategoryName
      }
    }
  ],
  Freight: 25.50,
  OrderTotal: 178.35,
  Shipment: {
    Shipper: {
      _id: shipper._id,
      ShipperID: shipper.ShipperID,
      CompanyName: shipper.CompanyName,
      Phone: shipper.Phone
    },
    ShipName: "Alfreds Futterkiste",
    ShipAddress: "Obere Str. 57",
    ShipCity: "Berlin",
    ShipCountry: "Germany"
  }
});


// 3. CustomerInfo:
let maxOrderID = db.orders.find().sort({OrderID: -1}).limit(1).toArray()[0].OrderID;
let newOrderID = maxOrderID + 1;

let chaiProduct = db.products.findOne({ProductID: 1});
let ikuraProduct = db.products.findOne({ProductID: 10});
let chaiCategory = db.categories.findOne({CategoryID: chaiProduct.CategoryID});
let ikuraCategory = db.categories.findOne({CategoryID: ikuraProduct.CategoryID});

let customer = db.customers.findOne({CustomerID: "ALFKI"});
let employee = db.employees.findOne({EmployeeID: 5});
let shipper = db.shippers.findOne({ShipperID: 2});

let chaiValue = 18.00 * 5 * (1 - 0);
let ikuraValue = 31.00 * 3 * (1 - 0.05);
let orderTotal = chaiValue + ikuraValue;

db.CustomerInfo.updateOne(
  { CustomerID: "ALFKI" },
  {
    $push: {
      Orders: {
        OrderID: newOrderID,
        Employee: {
          EmployeeID: employee.EmployeeID,
          FirstName: employee.FirstName,
          LastName: employee.LastName,
          Title: employee.Title
        },
        Dates: {
          OrderDate: new Date("2025-05-06"),
          RequiredDate: new Date("2025-05-15"),
        },
        Orderdetails: [
          {
            UnitPrice: 18.00,
            Quantity: 5,
            Discount: 0,
            Value: 90.00,
            product: {
              ProductID: chaiProduct.ProductID,
              ProductName: chaiProduct.ProductName,
              QuantityPerUnit: chaiProduct.QuantityPerUnit,
              CategoryID: chaiProduct.CategoryID,
              CategoryName: chaiCategory.CategoryName
            }
          },
          {
            UnitPrice: 31.00,
            Quantity: 3,
            Discount: 0.05,
            Value: 88.35,
            product: {
              ProductID: ikuraProduct.ProductID,
              ProductName: ikuraProduct.ProductName,
              QuantityPerUnit: ikuraProduct.QuantityPerUnit,
              CategoryID: ikuraProduct.CategoryID,
              CategoryName: ikuraCategory.CategoryName
            }
          }
        ],
        Freight: 25.50,
        OrderTotal: 178.35,
        Shipment: {
          Shipper: {
            _id: shipper._id,
            ShipperID: shipper.ShipperID,
            CompanyName: shipper.CompanyName,
            Phone: shipper.Phone
          },
          ShipName: "Alfreds Futterkiste",
          ShipAddress: "Obere Str. 57",
          ShipCity: "Berlin",
          ShipCountry: "Germany"
        }
      }
    }
  }
);
