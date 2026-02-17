import { LightningElement } from 'lwc';
import MarketplaceLabel from '@salesforce/label/c.MarketplaceLabel';
import CartLabel from '@salesforce/label/c.CartLabel';
import EnterTheNameLabel from '@salesforce/label/c.EnterTheNameLabel';

export default class SearchComponent extends LightningElement {
    labels = {
        MarketplaceLabel,
        CartLabel,
        EnterTheNameLabel
    };
}