import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        solo: Number,
        group: Number,
        fellow: Number,
        basecamper: Number
    }

    connect() {
        const solo = this.soloValue || 0
        const group = this.groupValue || 0
        const fellow = this.fellowValue || 0
        const basecamper = this.basecamperValue || 0

        const ctx = this.element.getContext("2d")
        const chart = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Solo', 'Group', 'Fellow', 'Basecamper'],
                datasets: [{
                    data: [solo, group, fellow, basecamper],
                    backgroundColor: ['#76cde1', '#2b3b69', '#deaf07', '#2d6a4f']
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '30%', // consistent inner hole size
                layout: { padding: 20 },
                plugins: {
                    legend: {
                        display: false // hide built-in legend
                    }
                },
                legendCallback: function(chart) {
                    const items = chart.data.labels.map((label, index) => {
                        const bgColor = chart.data.datasets[0].backgroundColor[index];
                        return `<span style="color:${bgColor}">${label}</span>`;
                    });
                    return `<div class="custom-legend">${items.join('')}</div>`;
                }
            }


        })
        const legendContainer = this.element.parentElement.nextElementSibling
        if (legendContainer && legendContainer.classList.contains('custom-legend')) {
            legendContainer.innerHTML = chart.data.labels.map((label, i) => {
                const color = chart.data.datasets[0].backgroundColor[i]
                return `
      <div style="display:flex;align-items:center;gap:6px;font-size:12px;">
        <span style="display:inline-block;width:12px;height:12px;background:${color};border-radius:2px;"></span>
        ${label}
      </div>
    `
            }).join('')
        }

        // Reflow on orientation change
        window.addEventListener("orientationchange", () => {
            setTimeout(() => chart.resize(), 250);
        });
    }
}
