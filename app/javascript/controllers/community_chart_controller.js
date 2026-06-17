import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {

        console.log("Community values:", {
            "labels": Object.values(this.element.dataset)[1],
            "data": Object.values(this.element.dataset)[0]
        })

        const rawLabels = Object.values(this.element.dataset)[1]
        const rawData = Object.values(this.element.dataset)[0]

        if (!rawLabels || !rawData) {
            console.warn("⚠️ Missing labels or data")
            return
        }

        const labels = rawLabels.split(",")
        const data = rawData.split(",").map(Number)

        const ctx = this.element.getContext("2d")
        const chart = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: labels,
                datasets: [{
                    label: "# of members",
                    data: data,
                    backgroundColor: ['#afb7bc','#deaf07','#2b3b69','#7bc8da',
                        '#865b8a','#7ca563', '#4e3d09','rgba(34,154,182,0.94)',
                        '#9e3955','#255c1a','#cd9343','#989ee8'
                         ],
                    hoverOffset: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '30%',
                layout: { padding: 20 },
                plugins: {
                    legend: {
                        display: false // hide default legend
                    }
                },
                // Custom legend builder
                legendCallback: (chart) => {
                    return chart.data.labels.map((label, index) => {
                        const color = chart.data.datasets[0].backgroundColor[index]
                        return `
              <div style="display:flex;align-items:center;gap:6px;font-size:12px;">
                <span style="display:inline-block;width:12px;height:12px;background:${color};border-radius:2px;"></span>
                ${label}
              </div>
            `
                    }).join('')
                }
            }
        })

        // Populate the legend container
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