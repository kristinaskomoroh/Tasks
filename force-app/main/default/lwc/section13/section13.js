import { LightningElement } from 'lwc';
import searchAccounts from '@salesforce/apex/AccountSearchRecords.searchAccounts';

export default class Section13 extends LightningElement {
    time1;
    time2;
    time3;
    isLoading = false;
    coinResult = '';
    userProfile = {
        name: 'Bob',
        surname: 'Bobinson',
    };
    searchKey = '';
    searchResult = [];

    updateTimes(){
        const now = new Date();
        const options = {
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: false, 
            timeZoneName: 'short'
        };
        this.time1 = this.formatTime(now, 'America/New_York', options);
        this.time2 = this.formatTime(now, 'Europe/London', options);
        this.time3 = this.formatTime(now, 'Asia/Tokyo', options);
    }

    formatTime(date, timeZone, options){
       return new Intl.DateTimeFormat('en-US', {... options, timeZone:timeZone}).format(date);
    }

    connectedCallback(){
        this.updateTimes();
        setInterval(() => this.updateTimes(), 1000);
        this.checkCriteria();
    }

    handleMouseEnter(event){
        const card = event.target;
        card.style.backgroundColor = '#0070d2';
        card.style.transition = 'background-color 0.5s ease-in-out';
    }

    handleMouseLeave(event){
        const card = event.target;
        card.style.backgroundColor = 'white';
    }

    handleFlip(){
        this.isLoading = true;
        setTimeout(() => {this.coinResult = Math.random() < 0.5 ? 'Heads' : 'Tails';  this.isLoading = false; setTimeout(() => {this.coinResult = '';}, 2000);}, 2000);
    }

    checkCriteria() {
        const user = { 
            id: 1, 
            name: 'Alice', 
            role: 'Admin', 
            status: 'Active' 
        };
        const criteria = { 
            role: 'Admin', 
            status: 'Active' 
        };
        const isMatch = this.matches(user, criteria);
        console.log('Is the user suitable?', isMatch); 
    }

    matches(target, source) {
        return Object.keys(source).every(key => 
            target.hasOwnProperty(key) && target[key] === source[key]
        );
    }

    handlePhoneNumber(event){
        const phoneInput = event.target;
        if(phoneInput.checkValidity()){
            console.log('Valid phone number');
        }else{
            phoneInput.reportValidity();
        }
    }

    setAttribute(key, value){
        this.userProfile[key] = value;
    }

    getAttribute(key){
        return this.userProfile[key] ? this.userProfile[key] : 'Not found';
    }

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

    findContactsByAccountName(accName){
        foundAccount = this.searchResult.find(
            item => item.accName === accName
        );
        return foundAccount ? foundAccount.contactsName : [];
    }

    compareValues(param1, param2){
        if(typeof param1 === 'string' && typeof param2 === 'string'){
            return param1.length >= param2.length ? param1 : param2;
        }
        if(typeof param1 === 'number' && typeof param2 === 'number'){
            return Math.max(param1, param2);
        }
    }
}