public with sharing class RedirectCustomExtension {
    public RedirectCustomExtension(ContactController mainController) {
    }

    public PageReference redirectPage(){
        PageReference pageRef = new PageReference('/apex/CustomContactListController');
        pageRef.setRedirect(true);
        return pageRef;
    }
}