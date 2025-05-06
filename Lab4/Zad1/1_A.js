show dbs

use north0

db.customers.find()

show collections

db.OrdersInfo.find();

db.products.find();

db.orders.aggregate([
  {
    $lookup: {
      from: "customers",
      localField: "CustomerID",
      foreignField: "CustomerID",
      as: "Customer"
    }
  },
  {
    $unwind: "$Customer"
  },
  {
    $lookup: {
      from: "employees",
      localField: "EmployeeID",
      foreignField: "EmployeeID",
      as: "Employee"
    }
  },
  {
    $unwind: "$Employee"
  },
  {
    $lookup: {
      from: "orderdetails",
      localField: "OrderID",
      foreignField: "OrderID",
      as: "Orderdetails"
    }
  },
  {
    $lookup: {
      from: "shippers",
      localField: "ShipVia",
      foreignField: "ShipperID",
      as: "Shipment.Shipper"
    }
  },
  {
    $unwind: "$Shipment.Shipper"
  },
  {
    $lookup: {
      from: "products",
      localField: "Orderdetails.ProductID",
      foreignField: "ProductID",
      as: "Orderdetails.product"
    }
  },
  {
    $unwind: "$Orderdetails"
  },
  {
    $unwind: "$Orderdetails.product"
  },
  {
    $lookup: {
      from: "categories",
      localField: "Orderdetails.product.CategoryID",
      foreignField: "CategoryID",
      as: "Orderdetails.product.category"
    }
  },
  {
    $unwind: "$Orderdetails.product.category"
  },
  {
    $group: {
      _id: "$_id",
      OrderID: { $first: "$OrderID" },
      Customer: { $first: { CustomerID: "$Customer.CustomerID", CompanyName: "$Customer.CompanyName", City: "$Customer.City", Country: "$Customer.Country" } },
      Employee: { $first: { EmployeeID: "$Employee.EmployeeID", FirstName: "$Employee.FirstName", LastName: "$Employee.LastName", Title: "$Employee.Title" } },
      Dates: { $first: { OrderDate: "$OrderDate", RequiredDate: "$RequiredDate", ShippedDate: "$ShippedDate" } },
      Freight: { $first: "$Freight" },
      Shipment: {
        $first: {
          Shipper: "$Shipment.Shipper",
          ShipName: "$ShipName",
          ShipAddress: "$ShipAddress",
          ShipCity: "$ShipCity",
          ShipCountry: "$ShipCountry"
        }
      },
      Orderdetails: {
        $push: {
          UnitPrice: "$Orderdetails.UnitPrice",
          Quantity: "$Orderdetails.Quantity",
          Discount: "$Orderdetails.Discount",
          Value: { $multiply: [ "$Orderdetails.UnitPrice", "$Orderdetails.Quantity", { $subtract: [ 1, "$Orderdetails.Discount" ] } ] },
          product: {
            ProductID: "$Orderdetails.product.ProductID",
            ProductName: "$Orderdetails.product.ProductName",
            QuantityPerUnit: "$Orderdetails.product.QuantityPerUnit",
            CategoryID: "$Orderdetails.product.CategoryID",
            CategoryName: "$Orderdetails.product.category.CategoryName"
          }
        }
      }
    }
  },
  {
    $project: {
      _id: 1,
      OrderID: 1,
      Customer: 1,
      Employee: 1,
      Dates: { OrderDate: 1, RequiredDate: 1 },
      Orderdetails: 1,
      Freight: 1,
      OrderTotal: { $sum: "$Orderdetails.Value" },
      Shipment: 1
    }
  },
  {
    $out: "OrdersInfo"
  }
]).pretty()

db.OrdersInfo.find().pretty()