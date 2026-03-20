import { LightningElement} from 'lwc';
import searchAccounts from '@salesforce/apex/AccountSearchRecords.searchAccounts';

export default class ContactSearch extends LightningElement {

    searchKey = '';
    searchResult = [];

    handleInputChange(event){
        this.searchKey = event.target.value;
    }

    handleSearch(){
        searchAccounts({searchItem: this.searchKey})
        .then(result => {
            this.searchResult = JSON.parse(result);
        })
        .catch(error => {
            console.error(error);
        });
    }
}