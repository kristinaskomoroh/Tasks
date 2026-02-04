public with sharing class RedirectExtension {
    public RedirectExtension(ApexPages.StandardController controller) {
    }

    public PageReference redirectPage(){
        PageReference pageRef = new PageReference('/apex/ContactsPage');
        pageRef.setRedirect(true);
        return pageRef;
    }
}