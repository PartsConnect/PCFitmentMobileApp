using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{
    public class MDLGetLanguageWiseLabels
    {
        public string TextContent { get; set; }
        public string DefaultLanguageCode { get; set; }
        public string Translated { get; set; }
    }
}
