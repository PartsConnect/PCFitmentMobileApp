using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{

    public class MDLGetFitmentsUploadDetails
    {
        public string checkunderprocess { get; set; }
        public string LastuploadfromUser { get; set; }
        public string UploadedTime { get; set; }
        public string ProcessingTime { get; set; }
        public string BrandName { get; set; }
        public string BrandID { get; set; }
        public string ValidFitment { get; set; }
        public string ValidPartType { get; set; }
        public string ValidPartNumber { get; set; }
        public string InvalidFitment { get; set; }
        public string InvalidPartType { get; set; }
        public string InvalidPartNumber { get; set; }
        public string usermakeRequestforadd { get; set; }
        public bool isFitmentAddRequstMade { get; set; } = false;
        public string TechnicalError { get; set; }
        public int NewACES { get; set; }
        public int NewPart { get; set; }
        public string reason { get; set; }
        public string IsMakeReq { get; set; }
        public string isFitmentAdded { get; set; }
        public string BLisFitmentAdded { get; set; } = "false";
    }
}
