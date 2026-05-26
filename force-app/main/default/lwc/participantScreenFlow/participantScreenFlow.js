import { LightningElement, api, wire } from 'lwc';
import { getRecord} from 'lightning/uiRecordApi';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import OrderNameLabel from '@salesforce/label/c.OrderNameLabel';
import DebitorNumberLabel from '@salesforce/label/c.DebitorNumberLabel';

import DEBITOR_NUMBER from '@salesforce/schema/Order.Applicant__r.Debitor_number__c';
import ORDER_NUMBER from '@salesforce/schema/Order.OrderNumber';

export default class ParticipantScreenFlow extends LightningElement {
    @api recordId;
    @api debitorNum;

    isLoading = true;
    isEditingMode = false;

    draftValue;

    labels = {
        OrderNameLabel,
        DebitorNumberLabel
    }

    @wire(getRecord, {recordId: '$recordId', fields: [DEBITOR_NUMBER, ORDER_NUMBER]})
    wiredOrder({data, error}){
        if(data){
            this.debitorNum = data.fields?.Applicant__r?.value?.fields?.Debitor_number__c?.value || '';
            this.orderName = data.fields?.OrderNumber?.value || '';
        }else if(error){
            this.handleError();
        }
    }

    get orderUrl(){
        return `/lightning/r/Order/${this.recordId}/view`;
    }

    handleNumberChange(event) {
        this.draftValue = event.target.value;
    }

    handleFormLoad(){
        this.isLoading = false;
    }

    confirmEdit() {
        this.debitorNum = this.draftValue;
        this.isEditingMode = false;
        this.dispatchEvent(new FlowAttributeChangeEvent('debitorNum', this.debitorNum));
    }

    cancelEdit() {
        this.draftValue = this.debitorNum;
        this.isEditingMode = false;
    }

    enableEditMode(){
        this.draftValue = this.debitorNum;
        this.isEditingMode = true;
    }

    handleError(error){
        const errorMsg = error?.body?.output?.errors?.[0]?.message
                      || error?.body?.message
                      || error?.message
                      || this.labels.ErrorMessageLabel;
        this.showToast(this.labels.ErrorLabel, errorMsg, this.labels.ErrorLabel);
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}