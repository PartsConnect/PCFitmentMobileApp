using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{
    public class MDLGetLanguages
    {
        public string Languageld { get; set; }
        public string LanguageCode { get; set; }
        public string LanguageName { get; set; }
    }
}
