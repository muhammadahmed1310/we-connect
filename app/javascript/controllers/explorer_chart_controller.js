import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {

        console.log("*********************************************************");
        console.log(Object.keys(this.element.dataset))
        console.log(Object.values(this.element.dataset))
        console.log("Stimulus values:", {
            "solo": Object.values(this.element.dataset)[2],
            "group": Object.values(this.element.dataset)[1]
        })
        console.log("*********************************************************");

        const fellow = parseInt(Object.values(this.element.dataset)[1] || "0", 10)
        const group = parseInt(Object.values(this.element.dataset)[2] || "0", 10)
        const solo = parseInt(Object.values(this.element.dataset)[3] || "0", 10)

        const ctx = this.element.getContext("2d")
        const chart= new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Solo', 'Group', 'Fellow'],
                datasets: [{
                    data: [solo, group,fellow],
                    backgroundColor: ['#76cde1', '#2b3b69','#deaf07']
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
