import { LightningElement, api, wire} from 'lwc';
import { updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from 'lightning/actions';
import LightningConfirm from 'lightning/confirm';
import getOrder from '@salesforce/apex/OrderController.getOrder';

import SaveLabel from '@salesforce/label/c.SaveLabel';
import CancelLabel from '@salesforce/label/c.CancelLabel';
import DebitorNumberMessage from '@salesforce/label/c.DebitorNumberMessage';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import ConfirmTheme from '@salesforce/label/c.ConfirmTheme';
import FormMessage from '@salesforce/label/c.FormMessage';
import InformationalLabel from '@salesforce/label/c.InformationalLabel';
import InformationalTheme from '@salesforce/label/c.InformationalTheme';
import Participant_status_message from '@salesforce/label/c.Participant_status_message';
import SuccessLabel from '@salesforce/label/c.SuccessLabel';
import ToastMessageStatusLabel from '@salesforce/label/c.ToastMessageStatusLabel';
import ErrorLabel from '@salesforce/label/c.ErrorLabel';
import ToastMessageFormLabel from '@salesforce/label/c.ToastMessageFormLabel';
import ToastMessageNumberLabel from '@salesforce/label/c.ToastMessageNumberLabel';
import FirstModalLabel from '@salesforce/label/c.FirstModalLabel';
import EnterNumberLabel from '@salesforce/label/c.EnterNumberLabel';
import OrderNameLabel from '@salesforce/label/c.OrderNameLabel';




export default class ParticipantConfirmationAction extends LightningElement {
    @api recordId;
    @api objectApiName;
    order;
    orderName;
    targetEntryStatus;
    targetOrderStatus;
    debitorNum;
    contactId;
    enteredNumber = '';
    entryToUpdate = null;
    isPreregistered = false;
    isFixed = false;
    isEditingMode = false;
    isLoading = true;

    labels = {
        SaveLabel,
        CancelLabel,
        DebitorNumberMessage,
        ConfirmLabel,
        ConfirmTheme,
        FormMessage,
        InformationalLabel,
        InformationalTheme,
        Participant_status_message,
        SuccessLabel,
        ToastMessageStatusLabel,
        ErrorLabel,
        ToastMessageFormLabel,
        ToastMessageNumberLabel,
        FirstModalLabel,
        EnterNumberLabel,
        OrderNameLabel
    }

    @wire(getOrder, { recordId: "$recordId" })
    wiredOrder({data, error}){
        if(data){
            this.order = data.order;
            this.isPreregistered = data.isEntryPreregistered;
            this.isFixed = data.isEntryFixed;
            this.targetEntryStatus = data.entryChangedStatus;
            this.targetOrderStatus = data.orderChangedStatus;
            this.entryToUpdate = data.order.Ticket__c;
            this.debitorNum = data.order.Applicant__r.Debitor_number__c;
            this.contactId = data.order.Applicant__c;
            this.orderName = data.order.Name;
            console.log('Data from wrapper ', data);
        }else if (error){
            const errorMsg = error?.body?.output?.errors?.[0]?.message
                      || error?.body?.message
                      || error?.message
                      || 'An error occurred';
            this.showToast(this.labels.ErrorLabel, errorMsg, this.labels.ErrorLabel);
        }
    }

    get isConfirmStep() {
        return this.isPreregistered;
    }

    get isEnterNumberStep() {
        return !this.debitorNum && this.isFixed;
    }

    get isEditFormStep() {
        return !!this.debitorNum && this.isFixed;
    }

    get orderUrl(){
        return `/lightning/r/Order/${this.recordId}/view`;
    }

    async handleConfirm(){
        try{
            const result = await LightningConfirm.open({
                message: this.labels.Participant_status_message,
                label: this.labels.InformationalLabel,
                theme: this.labels.InformationalTheme,
                });
            if(!result) return;
            await this.updateEntryStatus();
            this.isPreregistered = false;
            this.isFixed = true;
        }catch(error){
            const errorMsg = error?.body?.output?.errors?.[0]?.message
                      || error?.body?.message
                      || error?.message
                      || 'An error occurred while updating the status.';
            this.showToast(this.labels.ErrorLabel, errorMsg, this.labels.ErrorLabel);
        }
    }

    async updateEntryStatus(){
        if(!this.entryToUpdate){
            this.showToast(this.labels.ErrorLabel);
            return;
        }
        const fields = {}
        fields['Id'] = this.entryToUpdate;
        fields['Status__c'] = this.targetEntryStatus;
        const recordInput = {fields};
        await updateRecord(recordInput);
        this.showToast(this.labels.SuccessLabel, this.labels.ToastMessageStatusLabel, this.labels.SuccessLabel);
    }

    handleContactSuccess(event){
        const updatedFields = event.detail.fields;
        this.debitorNum = updatedFields.Debitor_number__c.value;
    }

    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    handleInputNumber(event){
        this.enteredNumber = event.target.value;
    }

    async handleForm(){
        const form = this.template.querySelector('.my-form');
        if(form){
            try{
                const confirmMessage = await LightningConfirm.open({
                    message: this.labels.FormMessage,
                    label: this.labels.ConfirmLabel,
                    theme: this.labels.ConfirmTheme,
                });
                if(confirmMessage){
                    const fieldsOrder = {Id: this.recordId, Ticket_status__c: this.targetOrderStatus};
                    const fieldsContact = {Id: this.contactId, Debitor_number__c: this.enteredNumber};
                    await Promise.all([
                    updateRecord({fields: fieldsOrder}),
                    updateRecord({fields: fieldsContact})
                ])
                this.showToast(this.labels.SuccessLabel, this.labels.ToastMessageFormLabel, this.labels.SuccessLabel);
                this.dispatchEvent(new CloseActionScreenEvent());
                }
            }catch(error){
                const errorMsg = error?.body?.output?.errors?.[0]?.message
                        || error?.body?.message
                        || error?.message
                        || 'An error occurred while saving data';
                this.showToast(this.labels.ErrorLabel, errorMsg, this.labels.ErrorLabel);
            }
        }
    }

    async handleNumber(){
        try{
            const confirmMessage = await LightningConfirm.open({
                message: this.labels.DebitorNumberMessage,
                label: this.labels.ConfirmLabel,
                theme: this.labels.ConfirmTheme,
            });
            if(confirmMessage){
                const fields = {}
                fields['Id'] = this.contactId;
                fields['Debitor_number__c'] = this.enteredNumber;
                const recordInput = {fields};
                await updateRecord(recordInput);
                this.showToast(this.labels.SuccessLabel, this.labels.ToastMessageNumberLabel, this.labels.SuccessLabel);
            }
        }catch(error){
            const errorMsg = error?.body?.output?.errors?.[0]?.message
                      || error?.body?.message
                      || error?.message
                      || 'An error occurred';
            this.showToast(this.labels.ErrorLabel, errorMsg, this.labels.ErrorLabel);
        }
    }

    enableEditMode(){
        this.isEditingMode = true;
    }

    handleFormLoad(){
        this.isLoading = false;
    }

    handleAction() {
        if(this.isConfirmStep) this.handleConfirm();
        if(this.isEditFormStep) this.handleForm();
        if(this.isEnterNumberStep) this.handleNumber();
    }

    confirmEdit() {
        const form = this.template.querySelector('.my-form');
        if (form) {
            form.submit();
        }
        this.isEditingMode = false;
    }

    cancelEdit() {
        const inputField = this.template.querySelector('.debitor-input');
        if(inputField){
            inputField.reset();
        }
        this.isEditingMode = false;
    }
}