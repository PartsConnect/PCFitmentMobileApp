namespace PCFitment_API.Models
{

    public class MDLInheritedParts
    {
        public string Id { get; set; }
        public string TenantID { get; set; }
        public string PartNumber { get; set; }
        public string ASIN { get; set; }
        public string ManufactureLabel { get; set; }
        public string PartDescription { get; set; }
        public string BrandID { get; set; }
        public string ParentPartNumber { get; set; }
        public string PartType { get; set; }
        public string Fitments { get; set; }

        public string NewPartNumber { get; set; }
        public string NewASIN { get; set; }
        public string ParentPartID { get; set; }
        public string PartTerminologyID { get; set; }
        public string InheritBrandID { get; set; }
    }
}
