using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{
    public class MDLRequestDataInExcel
    {
        public string tenantID { get; set; }
        public string ReqType { get; set; }
    }
}
