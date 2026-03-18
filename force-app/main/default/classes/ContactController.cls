public with sharing class ContactController {
    public String filterId { get; set; }
    private ApexPages.StandardSetController setCon;

    public ContactController(){
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Name, Email, Phone FROM Contact LIMIT 500]));
    }

    public List<Contact> getContactList() {
        return (List<Contact>) setCon.getRecords();
    }

    public List<SelectOption> getListViewOptions() {
        return setCon.getListViewOptions();
    }

    public PageReference updateFilter(){
        setCon.setFilterId(filterId);
        return null;
        
    }

    public void next() {
        setCon.next();
    }

    public void previous() {
        setCon.previous();
    }

    public Boolean getHasNext() {
        return setCon.getHasNext();
    }

    public Boolean getHasPrevious() {
        return setCon.getHasPrevious();
    }

    public Integer getPageNumber() {
        return setCon.getPageNumber();
    }

    public Integer getResultSize() {
        return setCon.getResultSize();
    }

    public Integer getPageSize() {
        return setCon.getPageSize();
    }

    public void setPageSize(Integer size) {
        setCon.setPageSize(size);
    }


    public List<Contact> getSingleContact() {
        Id contactId = ApexPages.currentPage().getParameters().get('id');
        if(contactId == null){
            return new List<Contact>();
        }
        return [SELECT Name, Email, Phone, Summary_price__c, Amount__c, Is_title_approved__c FROM Contact WHERE Id = :contactId];
    }


}