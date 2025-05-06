show dbs

use north0

show collections

db.OrdersInfo.find({
  "Dates.OrderDate": {
    $gte: ISODate("1997-01-01"),
    $lt: ISODate("1998-01-01")
  },
  "Orderdetails.product.CategoryName": "Confections"
}).count()



//1. Oryginalne kolekcje:
db.customers.aggregate([
  {
    $lookup: {
      from: "orders",
      localField: "CustomerID",
      foreignField: "CustomerID",
      as: "Orders"
    }
  },
  { $unwind: "$Orders" },
  {
    $match: {
      "Orders.OrderDate": {
        $gte: new ISODate("1997-01-01"),
        $lt: new ISODate("1998-01-01")
      }
    }
  },
  {
    $lookup: {
      from: "orderdetails",
      localField: "Orders.OrderID",
      foreignField: "OrderID",
      as: "Orderdetails"
    }
  },
  { $unwind: "$Orderdetails" },
  {
    $lookup: {
      from: "products",
      localField: "Orderdetails.ProductID",
      foreignField: "ProductID",
      as: "Product"
    }
  },
  { $unwind: "$Product" },
  {
    $lookup: {
      from: "categories",
      localField: "Product.CategoryID",
      foreignField: "CategoryID",
      as: "Category"
    }
  },
  { $unwind: "$Category" },
  { $match: { "Category.CategoryName": "Confections" } },
  {
    $group: {
      _id: "$CustomerID",
      CompanyName: { $first: "$CompanyName" },
      ConfectionsSale: {
        $sum: {
          $multiply: [
            "$Orderdetails.UnitPrice",
            "$Orderdetails.Quantity",
            { $subtract: [1, "$Orderdetails.Discount"] }
          ]
        }
      }
    }
  },
  {
    $project: {
      _id: 0,
      CustomerID: "$_id",
      CompanyName: 1,
      ConfectionsSale: 1
    }
  }
])

//2. Z kolekcji OrdersInfo:
db.OrdersInfo.aggregate([
  {
    $match: {
      "Dates.OrderDate": {
        $gte: new ISODate("1997-01-01"),
        $lt: new ISODate("1998-01-01")
      }
    }
  },
  { $unwind: "$Orderdetails" },
//  {
////    $match: {
////      "Orderdetails.product.CategoryName": "Confections"
////    }
//  },
  {
    $group: {
      _id: "$Customer.CustomerID",
//      CompanyName: { $first: "$Customer.CompanyName" },
      ConfectionsSale97: { $sum: "$Orderdetails.Value" }
    }
  },
  {
    $project: {
      _id: 0,
      CustomerID: "$_id",
      CompanyName: 1,
      ConfectionsSale97: 1
    }
  }
])

// 3. Z kolekcji CustomerInfo:
db.CustomerInfo.aggregate([
  { $unwind: "$Orders" },
  {
    $match: {
      "Orders.Dates.OrderDate": {
        $gte: new ISODate("1997-01-01"),
        $lt: new ISODate("1998-01-01")
      }
    }
  },
  { $unwind: "$Orders.Orderdetails" },
  {
    $match: {
      "Orders.Orderdetails.product.CategoryName": "Confections"
    }
  },
  {
    $group: {
      _id: "$CustomerID",
      CompanyName: { $first: "$CompanyName" },
      ConfectionsSale97: { $sum: "$Orders.Orderdetails.Value" }
    }
  },
  {
    $project: {
      _id: 0,
      CustomerID: "$_id",
      CompanyName: 1,
      ConfectionsSale97: 1
    }
  }
])
