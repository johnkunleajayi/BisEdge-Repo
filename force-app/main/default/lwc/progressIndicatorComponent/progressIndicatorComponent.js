import { LightningElement, api } from 'lwc';
import progressBar from '@salesforce/resourceUrl/progressbarjs';
import { loadScript } from 'lightning/platformResourceLoader';

export default class ProgressBars extends LightningElement {
    @api type; // 'line', 'circle', or 'semi-circle'
    @api value; // Progress value (0 to 100)

    progressBarLoaded = false;
    progressBarInstance = null; // To store the current ProgressBar instance

    get isLine() {
        return this.type === 'line';
    }

    get isCircle() {
        return this.type === 'circle';
    }

    get isSemiCircle() {
        return this.type === 'semi-circle';
    }

    renderedCallback() {
        if (this.progressBarLoaded) {
            return;
        }
        this.progressBarLoaded = true;
        loadScript(this, progressBar)
            .then(() => {
                this.initializeProgressBar();
            })
            .catch((error) => {
                console.error('Error loading progress bar script', error);
            });
    }

    disconnectedCallback() {
        if (this.progressBarInstance) {
            try {
                this.progressBarInstance.destroy();
            } catch (error) {
                console.warn('Error destroying ProgressBar instance:', error.message);
            }
            this.progressBarInstance = null;
        }
    }

    initializeProgressBar() {
        const progressValue = this.value / 100; // Convert the value to a 0–1 range

        const getColor = (progress) => {
            const red = { r: 196, g: 30, b: 58 }; // #C41E3A
            const orange = { r: 242, g: 140, b: 40 }; // #F28C28
            const yellow = { r: 255, g: 215, b: 0 }; // #FFD700
            const green = { r: 0, g: 128, b: 0 }; // #008000

            if (progress <= 0.33) {
                const stageProgress = progress / 0.33;
                const r = Math.round(red.r + (orange.r - red.r) * stageProgress);
                const g = Math.round(red.g + (orange.g - red.g) * stageProgress);
                const b = Math.round(red.b + (orange.b - red.b) * stageProgress);
                return `rgb(${r}, ${g}, ${b})`;
            } else if (progress <= 0.66) {
                const stageProgress = (progress - 0.33) / 0.33;
                const r = Math.round(orange.r + (yellow.r - orange.r) * stageProgress);
                const g = Math.round(orange.g + (yellow.g - orange.g) * stageProgress);
                const b = Math.round(orange.b + (yellow.b - orange.b) * stageProgress);
                return `rgb(${r}, ${g}, ${b})`;
            } else {
                const stageProgress = (progress - 0.66) / 0.34;
                const r = Math.round(yellow.r + (green.r - yellow.r) * stageProgress);
                const g = Math.round(yellow.g + (green.g - yellow.g) * stageProgress);
                const b = Math.round(yellow.b + (green.b - yellow.b) * stageProgress);
                return `rgb(${r}, ${g}, ${b})`;
            }
        };

        const container =
            this.isLine
                ? this.template.querySelector('.line-container')
                : this.isCircle
                ? this.template.querySelector('.circle-container')
                : this.template.querySelector('.semi-container');

        if (this.progressBarInstance) {
            try {
                this.progressBarInstance.destroy();
            } catch (error) {
                console.warn('Error destroying ProgressBar instance:', error.message);
            }
            this.progressBarInstance = null;
        }

        const progressBarConfig = {
            strokeWidth: this.isLine ? 4 : this.isCircle ? 25 : 8,
            trailWidth: this.isLine ? 0.5 : this.isCircle ? 25 : 8,
            from: { color: getColor(0) },
            to: { color: getColor(1) },
            text: {
                value: '0%',
                className: 'progress-text',
                style: {
                    color: 'black',
                    position: 'absolute',
                    top: this.isCircle || this.isSemiCircle ? '50%' : '-30px',
                    left: this.isCircle || this.isSemiCircle ? '50%' : '0',
                    transform: this.isCircle || this.isSemiCircle ? 'translate(-50%, -50%)' : null,
                    padding: 0,
                    margin: 0,
                },
            },
            step: (state, shape) => {
                const progress = shape.value();
                const color = getColor(progress);
                shape.path.setAttribute('stroke', color);
                shape.setText(Math.round(progress * 100) + ' %');
            },
        };

        if (this.isLine) {
            this.progressBarInstance = new ProgressBar.Line(container, progressBarConfig);
        } else if (this.isCircle) {
            this.progressBarInstance = new ProgressBar.Circle(container, progressBarConfig);
        } else if (this.isSemiCircle) {
            this.progressBarInstance = new ProgressBar.SemiCircle(container, progressBarConfig);
        }

        this.progressBarInstance.animate(progressValue, { duration: 2000 });
    }
}