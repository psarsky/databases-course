namespace EntityFramework;

public class Company
{
    public int CompanyID { get; set; }
    public string? CompanyName { get; set; }
    public string? Street { get; set; }
    public string? City { get; set; }
    public string? ZipCode { get; set; }
    
    public override string? ToString()
    {
        return CompanyName;
    }
}
