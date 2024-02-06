using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{

    public class MDLGetMyPartsAndFitment
    {
        public string ID { get; set; }
        public string PartTerminologyID { get; set; }
        public string PartTypeName { get; set; }
        public string ASIN { get; set; }
        public string BrandID { get; set; }
        public string ManufactureLabel { get; set; }
        public string PartDescription { get; set; }
        public string TenantID { get; set; }
        public string IsAmazonFit { get; set; }
        public string PartNumber { get; set; }
        public string CollectionID { get; set; }
        public string Fitmentsnum { get; set; }
        public string SavedFitmentsCount { get; set; }
        public string ErrorFitmentsCount { get; set; }

    }

    public class MDLGetMyPartsAndFitmentInfo
    {
        public List<MDLGetMyPartsAndFitment> MyPartsAndFitmentList { get; set; }

        public MDLGetMyPartsAndFitmentInfo()
        {
            MyPartsAndFitmentList = new List<MDLGetMyPartsAndFitment>();
        }

    }
}
