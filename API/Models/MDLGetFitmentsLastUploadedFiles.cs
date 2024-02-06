using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{

    public class MDLGetFitmentsLastUploadedFiles
    {
        public string userfilesid { get; set; }
        public string userid { get; set; }
        public string filepath { get; set; }
        public string filename { get; set; }
        public string filestatus { get; set; }
        public string reason { get; set; }
        public string createddate { get; set; }
        public string IsAddData { get; set; }
    }
}
