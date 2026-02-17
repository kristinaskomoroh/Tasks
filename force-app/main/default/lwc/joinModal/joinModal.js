import { LightningElement, api } from 'lwc';
import LastNameLabel from '@salesforce/label/c.LastNameLabel';
import EmailLabel from '@salesforce/label/c.EmailLabel';
import BirthdayDateLabel from '@salesforce/label/c.BirthdayDateLabel';
import FirstNameLabel from '@salesforce/label/c.FirstNameLabel';
import MobilePhoneLabel from '@salesforce/label/c.MobilePhoneLabel';
import CancelLabel from '@salesforce/label/c.CancelLabel';
import SaveLabel from '@salesforce/label/c.SaveLabel';
import NewUserLabel from '@salesforce/label/c.NewUserLabel';

export default class JoinModal extends LightningElement {

    @api
    showJoinModal = false;

    labels = {
        LastNameLabel,
        EmailLabel,
        BirthdayDateLabel,
        FirstNameLabel,
        MobilePhoneLabel,
        CancelLabel,
        SaveLabel,
        NewUserLabel
    };

     closeJoinModal() {
        this.dispatchEvent(
            new CustomEvent(
                'closejoin'
            )
        );
    }
}