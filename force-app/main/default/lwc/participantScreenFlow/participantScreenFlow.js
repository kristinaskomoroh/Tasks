import { LightningElement, api, wire } from 'lwc';
import { getRecord} from 'lightning/uiRecordApi';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

import OrderNameLabel from '@salesforce/label/c.OrderNameLabel';

import DEBITOR_NUMBER from '@salesforce/schema/Order.Applicant__r.Debitor_number__c';

export default class ParticipantScreenFlow extends LightningElement {
    @api recordId;
    @api orderName
    _debitorNum;

    isLoading = true;
    isEditingMode = false;

    draftValue;

    labels = {
        OrderNameLabel
    }

    @api
    get debitorNum() {
        return this._debitorNum;
    }

    set debitorNum(value) {
        this._debitorNum = value;
        if (!this.isEditingMode) {
            this.draftValue = value || '';
        }
    }

    @wire(getRecord, {recordId: '$recordId', fields: DEBITOR_NUMBER})
    wiredOrder({data, error}) {
        if (data) {
            if (!this._debitorNum) {
                this._debitorNum = data.fields?.Applicant__r?.value?.fields?.Debitor_number__c?.value || '';
                this.dispatchEvent(new FlowAttributeChangeEvent('debitorNum', this._debitorNum));
            }
        } else if (error) {
            this.handleError(error);
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
        this._debitorNum = this.draftValue;
        this.isEditingMode = false;
        this.dispatchEvent(new FlowAttributeChangeEvent('debitorNum', this._debitorNum));
    }

    cancelEdit() {
        this.draftValue = this._debitorNum;
        this.isEditingMode = false;
    }

    enableEditMode(){
        this.draftValue = this._debitorNum;
        this.isEditingMode = true;
    }

    handleError(error){
        const errorMsg = error?.body?.output?.errors?.[0]?.message
                      || error?.body?.message
                      || error?.message
                      || this.labels.ErrorMessageLabel;
        this.showToast(this.labels.ErrorLabel, errorMsg, this.labels.ErrorLabel);
    }
}