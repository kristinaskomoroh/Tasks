import { LightningElement } from 'lwc';
import WelcomeLabel from '@salesforce/label/c.WelcomeLabel';
import JoinLabel from '@salesforce/label/c.JoinLabel';
import SignInLabel from '@salesforce/label/c.SignInLabel';

export default class LoginSideBar extends LightningElement {

    labels = {
        WelcomeLabel,
        JoinLabel,
        SignInLabel
    };

    openModalJoin() {
        this.dispatchEvent(
            new CustomEvent(
                'joinclicked',
            )
        );
    }

    openModalSign() {
        this.dispatchEvent(
            new CustomEvent(
                'signinclicked',
            )
        );
    }
}