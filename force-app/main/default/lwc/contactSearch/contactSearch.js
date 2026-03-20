import { LightningElement, api } from 'lwc';


export default class ContactSearch extends LightningElement {

    @api searchResult = [];

    findContactsByAccountName(accName){
        foundAccount = this.searchResult.find(
            item => item.accName === accName
        );
        return foundAccount ? foundAccount.contactsName : [];
    }
}