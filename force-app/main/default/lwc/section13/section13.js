import { LightningElement} from 'lwc';


export default class Section13 extends LightningElement {
    time1;
    time2;
    time3;
    isLoading = false;
    coinResult = '';
    userProfile = {
        name: 'Bob',
        surname: 'Bobinson',
    };

    updateTimes(){
        const now = new Date();
        const options = {
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: false,
            timeZoneName: 'short'
        };
        this.time1 = this.formatTime(now, 'America/New_York', options);
        this.time2 = this.formatTime(now, 'Europe/London', options);
        this.time3 = this.formatTime(now, 'Asia/Tokyo', options);
    }

    formatTime(date, timeZone, options){
       return new Intl.DateTimeFormat('en-US', {... options, timeZone:timeZone}).format(date);
    }

    connectedCallback(){
        this.updateTimes();
        setInterval(() => this.updateTimes(), 1000);
        this.checkCriteria();
    }

    handleMouseEnter(event){
        const card = event.target;
        card.style.backgroundColor = '#0070d2';
        card.style.transition = 'background-color 0.5s ease-in-out';
    }

    handleMouseLeave(event){
        const card = event.target;
        card.style.backgroundColor = 'white';
    }

    checkCriteria() {
        const user = {
            id: 1,
            name: 'Alice',
            role: 'Admin',
            status: 'Active'
        };
        const criteria = {
            role: 'Admin',
            status: 'Active'
        };
        const isMatch = this.matches(user, criteria);
        console.log('Is the user suitable?', isMatch);
    }

    matches(target, source) {
        return Object.keys(source).every(key =>
            target.hasOwnProperty(key) && target[key] === source[key]
        );
    }

    setAttribute(key, value){
        this.userProfile[key] = value;
    }

    getAttribute(key){
        return this.userProfile[key] ? this.userProfile[key] : 'Not found';
    }

    compareValues(param1, param2){
        const isNum1 = !NaN(param1) && param1 !== '' && param1 !== null;
        const isNum2 = !NaN(param2) && param2 !== '' && param2 !== null;
        if(isNum1 && isNum2){
            return Math.max(Number(param1), Number(param2));
        }
        if(typeof param1 === 'string' && typeof param2 === 'string'){
            return param1.length >= param2.length ? param1 : param2;
        }
    }
}