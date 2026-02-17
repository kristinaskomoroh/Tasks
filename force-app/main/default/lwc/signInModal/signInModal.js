import { LightningElement, api } from 'lwc';
import FirstNameLabel from '@salesforce/label/c.FirstNameLabel';
import MobilePhoneLabel from '@salesforce/label/c.MobilePhoneLabel';
import CancelLabel from '@salesforce/label/c.CancelLabel';
import SaveLabel from '@salesforce/label/c.SaveLabel';
import SignInLabel from '@salesforce/label/c.SignInLabel';


export default class SignInModal extends LightningElement {

    @api
    showSignInModal = false;

    labels = {
        FirstNameLabel,
        MobilePhoneLabel,
        CancelLabel,
        SaveLabel,
        SignInLabel
    };

    closeSignModal() {
        this.dispatchEvent(
            new CustomEvent(
                'closesignin'
            )
        );
    }
}