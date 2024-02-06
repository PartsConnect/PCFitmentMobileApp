using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{

    public class MDLGetLangAndTermcndAndPrivacyplc
    {
        public IEnumerable<MDLGetLanguageWiseLabels> LanguageWiseLabels { get; set; }
        public MDLGetTermsAndConditionAndPrivacyPolicy TermsAndConditionAndPrivacyPolicies { get; set; }
    }
}
