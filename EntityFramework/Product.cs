public class Product
{
    public int ProductID { get; set; }
    public string? ProductName { get; set; }
    public int UnitsInStock { get; set; }
    public override string ToString(){
        if (ProductName == null)
        {
            return "No product name";
        }
        return $"{ProductName} - {UnitsInStock}pcs";
    }
}