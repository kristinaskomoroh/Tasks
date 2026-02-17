import { LightningElement } from 'lwc';

export default class PhoneNumber extends LightningElement {

    handlePhoneNumber(event){
        const phoneInput = event.target;
        if(phoneInput.checkValidity()){
            console.log('Valid phone number');
        }else{
            phoneInput.reportValidity();
        }
    }
}