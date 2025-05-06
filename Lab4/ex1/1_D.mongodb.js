// 1. Oryginalne kolekcje:
use("north0");

db.orders.aggregate([
  {
    $lookup: {
      from: "orderdetails",
      localField: "OrderID",
      foreignField: "OrderID",
      as: "details",
    },
  },
  { $unwind: "$details" },
  {
    $lookup: {
      from: "customers",
      localField: "CustomerID",
      foreignField: "CustomerID",
      as: "customer",
    },
  },
  { $unwind: "$customer" },
  {
    $project: {
      CustomerID: "$CustomerID",
      CompanyName: "$customer.CompanyName",
      year: { $year: "$OrderDate" },
      month: { $month: "$OrderDate" },
      orderValue: {
        $multiply: [
          "$details.UnitPrice",
          "$details.Quantity",
          { $subtract: [1, "$details.Discount"] },
        ],
      },
    },
  },
  {
    $group: {
      _id: {
        CustomerID: "$CustomerID",
        CompanyName: "$CompanyName",
        year: "$year",
        month: "$month",
      },
      totalSales: { $sum: "$orderValue" },
    },
  },
  {
    $group: {
      _id: {
        CustomerID: "$_id.CustomerID",
        CompanyName: "$_id.CompanyName",
      },
      Sale: {
        $push: {
          Year: "$_id.year",
          Month: "$_id.month",
          Total: { $round: ["$totalSales", 2] },
        },
      },
    },
  },
  {
    $project: {
      _id: 0,
      CustomerID: "$_id.CustomerID",
      CompanyName: "$_id.CompanyName",
      Sale: 1,
    },
  },
  { $sort: { CustomerID: 1 } },
]);

// 2. OrdersInfo:
use("north0");

db.OrdersInfo.aggregate([
  {
    $project: {
      CustomerID: "$Customer.CustomerID",
      CompanyName: "$Customer.CompanyName",
      year: { $year: "$Dates.OrderDate" },
      month: { $month: "$Dates.OrderDate" },
      orderValue: "$OrderTotal",
    },
  },
  {
    $group: {
      _id: {
        CustomerID: "$CustomerID",
        CompanyName: "$CompanyName",
        year: "$year",
        month: "$month",
      },
      totalSales: { $sum: "$orderValue" },
    },
  },
  {
    $group: {
      _id: {
        CustomerID: "$_id.CustomerID",
        CompanyName: "$_id.CompanyName",
      },
      Sale: {
        $push: {
          Year: "$_id.year",
          Month: "$_id.month",
          Total: { $round: ["$totalSales", 2] },
        },
      },
    },
  },
  {
    $project: {
      _id: 0,
      CustomerID: "$_id.CustomerID",
      CompanyName: "$_id.CompanyName",
      Sale: 1,
    },
  },
  { $sort: { CustomerID: 1 } },
]);

// 3. CustomerInfo:
use("north0");

db.CustomerInfo.aggregate([
  { $unwind: "$Orders" },
  {
    $project: {
      CustomerID: "$CustomerID",
      CompanyName: "$CompanyName",
      year: { $year: "$Orders.Dates.OrderDate" },
      month: { $month: "$Orders.Dates.OrderDate" },
      orderValue: "$Orders.OrderTotal",
    },
  },
  {
    $group: {
      _id: {
        CustomerID: "$CustomerID",
        CompanyName: "$CompanyName",
        year: "$year",
        month: "$month",
      },
      totalSales: { $sum: "$orderValue" },
    },
  },
  {
    $group: {
      _id: {
        CustomerID: "$_id.CustomerID",
        CompanyName: "$_id.CompanyName",
      },
      Sale: {
        $push: {
          Year: "$_id.year",
          Month: "$_id.month",
          Total: { $round: ["$totalSales", 2] },
        },
      },
    },
  },
  {
    $project: {
      _id: 0,
      CustomerID: "$_id.CustomerID",
      CompanyName: "$_id.CompanyName",
      Sale: 1,
    },
  },
  { $sort: { CustomerID: 1 } },
]);
