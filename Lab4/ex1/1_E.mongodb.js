// 1. Oryginalne kolekcje:
use("north0");

let maxOrderID = db.orders
  .find()
  .sort({ OrderID: -1 })
  .limit(1)
  .toArray()[0].OrderID;
let newOrderID = maxOrderID + 1;

db.orders.insertOne({
  OrderID: newOrderID,
  CustomerID: "ALFKI",
  EmployeeID: 5,
  OrderDate: new Date("2025-05-06"),
  RequiredDate: new Date("2025-05-15"),
  ShippedDate: null,
  ShipVia: 2,
  Freight: 25.5,
  ShipName: "Alfreds Futterkiste",
  ShipAddress: "Obere Str. 57",
  ShipCity: "Berlin",
  ShipRegion: null,
  ShipPostalCode: "12209",
  ShipCountry: "Germany",
});

db.orderdetails.insertMany([
  {
    OrderID: newOrderID,
    ProductID: 1,
    UnitPrice: 18.0,
    Quantity: 5,
    Discount: 0.0,
  },
  {
    OrderID: newOrderID,
    ProductID: 10,
    UnitPrice: 31.0,
    Quantity: 3,
    Discount: 0.05,
  },
]);

use("north0");
db.orders.find().sort({ OrderID: -1 }).limit(1);
use("north0");
db.orderdetails.find().sort({ OrderID: -1 }).limit(2);

// 2. OrdersInfo:
use("north0");

let maxOrderID_ = db.OrdersInfo.find()
  .sort({ OrderID: -1 })
  .limit(1)
  .toArray()[0].OrderID;
let newOrderID_ = maxOrderID_ + 1;

let chaiProduct = db.products.findOne({ ProductID: 1 });
let ikuraProduct = db.products.findOne({ ProductID: 10 });
let chaiCategory = db.categories.findOne({
  CategoryID: chaiProduct.CategoryID,
});
let ikuraCategory = db.categories.findOne({
  CategoryID: ikuraProduct.CategoryID,
});

let customer = db.customers.findOne({ CustomerID: "ALFKI" });
let employee = db.employees.findOne({ EmployeeID: 5 });
let shipper = db.shippers.findOne({ ShipperID: 2 });

let chaiValue = 18.0 * 5 * (1 - 0);
let ikuraValue = 31.0 * 3 * (1 - 0.05);
let orderTotal = chaiValue + ikuraValue;

db.OrdersInfo.insertOne({
  OrderID: newOrderID_,
  Customer: {
    CustomerID: customer.CustomerID,
    CompanyName: customer.CompanyName,
    City: customer.City,
    Country: customer.Country,
  },
  Employee: {
    EmployeeID: employee.EmployeeID,
    FirstName: employee.FirstName,
    LastName: employee.LastName,
    Title: employee.Title,
  },
  Dates: {
    OrderDate: new Date("2025-05-06"),
    RequiredDate: new Date("2025-05-15"),
  },
  Orderdetails: [
    {
      UnitPrice: 18.0,
      Quantity: 5,
      Discount: 0,
      Value: 90.0,
      product: {
        ProductID: chaiProduct.ProductID,
        ProductName: chaiProduct.ProductName,
        QuantityPerUnit: chaiProduct.QuantityPerUnit,
        CategoryID: chaiProduct.CategoryID,
        CategoryName: chaiCategory.CategoryName,
      },
    },
    {
      UnitPrice: 31.0,
      Quantity: 3,
      Discount: 0.05,
      Value: 88.35,
      product: {
        ProductID: ikuraProduct.ProductID,
        ProductName: ikuraProduct.ProductName,
        QuantityPerUnit: ikuraProduct.QuantityPerUnit,
        CategoryID: ikuraProduct.CategoryID,
        CategoryName: ikuraCategory.CategoryName,
      },
    },
  ],
  Freight: 25.5,
  OrderTotal: 178.35,
  Shipment: {
    Shipper: {
      _id: shipper._id,
      ShipperID: shipper.ShipperID,
      CompanyName: shipper.CompanyName,
      Phone: shipper.Phone,
    },
    ShipName: "Alfreds Futterkiste",
    ShipAddress: "Obere Str. 57",
    ShipCity: "Berlin",
    ShipCountry: "Germany",
  },
});

use("north0");
db.OrdersInfo.find().sort({ OrderID: -1 }).limit(1);

// 3. CustomerInfo:
use("north0");

let maxOrderID__ = db.orders
  .find()
  .sort({ OrderID: -1 })
  .limit(1)
  .toArray()[0].OrderID;
let newOrderID__ = maxOrderID__ + 1;

let chaiProduct_ = db.products.findOne({ ProductID: 1 });
let ikuraProduct_ = db.products.findOne({ ProductID: 10 });
let chaiCategory_ = db.categories.findOne({
  CategoryID: chaiProduct_.CategoryID,
});
let ikuraCategory_ = db.categories.findOne({
  CategoryID: ikuraProduct_.CategoryID,
});

let customer_ = db.customers.findOne({ CustomerID: "ALFKI" });
let employee_ = db.employees.findOne({ EmployeeID: 5 });
let shipper_ = db.shippers.findOne({ ShipperID: 2 });

let chaiValue_ = 18.0 * 5 * (1 - 0);
let ikuraValue_ = 31.0 * 3 * (1 - 0.05);
let orderTotal_ = chaiValue_ + ikuraValue_;

db.CustomerInfo.updateOne(
  { CustomerID: "ALFKI" },
  {
    $push: {
      Orders: {
        OrderID: newOrderID__,
        Employee: {
          EmployeeID: employee_.EmployeeID,
          FirstName: employee_.FirstName,
          LastName: employee_.LastName,
          Title: employee_.Title,
        },
        Dates: {
          OrderDate: new Date("2025-05-06"),
          RequiredDate: new Date("2025-05-15"),
        },
        Orderdetails: [
          {
            UnitPrice: 18.0,
            Quantity: 5,
            Discount: 0,
            Value: 90.0,
            product: {
              ProductID: chaiProduct_.ProductID,
              ProductName: chaiProduct_.ProductName,
              QuantityPerUnit: chaiProduct_.QuantityPerUnit,
              CategoryID: chaiProduct_.CategoryID,
              CategoryName: chaiCategory_.CategoryName,
            },
          },
          {
            UnitPrice: 31.0,
            Quantity: 3,
            Discount: 0.05,
            Value: 88.35,
            product: {
              ProductID: ikuraProduct_.ProductID,
              ProductName: ikuraProduct_.ProductName,
              QuantityPerUnit: ikuraProduct_.QuantityPerUnit,
              CategoryID: ikuraProduct_.CategoryID,
              CategoryName: ikuraCategory_.CategoryName,
            },
          },
        ],
        Freight: 25.5,
        OrderTotal: 178.35,
        Shipment: {
          Shipper: {
            _id: shipper_._id,
            ShipperID: shipper_.ShipperID,
            CompanyName: shipper_.CompanyName,
            Phone: shipper_.Phone,
          },
          ShipName: "Alfreds Futterkiste",
          ShipAddress: "Obere Str. 57",
          ShipCity: "Berlin",
          ShipCountry: "Germany",
        },
      },
    },
  }
);

use("north0");
db.CustomerInfo.find({ CustomerID: "ALFKI" });
