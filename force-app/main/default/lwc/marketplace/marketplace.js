import { LightningElement } from 'lwc';

export default class Marketplace extends LightningElement {
    isJoinModalOpen = false;
    isSignModalOpen = false;

     openModalJoin() {
        console.log('Кнопка нажата!');
        this.isJoinModalOpen = true; 
    }

    closeJoinModal() {
        this.isJoinModalOpen = false;
    }

    openModalSign(){
         console.log('Кнопка нажата!');
        this.isSignModalOpen = true;
    }

    closeSignModal(){
        this.isSignModalOpen = false;
    }


    
}