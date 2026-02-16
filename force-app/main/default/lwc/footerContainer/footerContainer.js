import { LightningElement } from 'lwc';
import SuperLabel from '@salesforce/label/c.SuperLabel';
import DealsLabel from '@salesforce/label/c.DealsLabel';
import ViewMoreLabel from '@salesforce/label/c.ViewMoreLabel';

export default class FooterContainer extends LightningElement {

    labels = {
        SuperLabel,
        DealsLabel,
        ViewMoreLabel
    }
}