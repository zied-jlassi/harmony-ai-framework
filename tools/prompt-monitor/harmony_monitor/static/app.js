/**
 * Harmony Prompt Monitor - Dashboard Application
 * Team Learning Journal for Prompt Effectiveness
 */

// Configuration
const API_BASE = '';
const REFRESH_INTERVAL = 5000;
const PAGE_SIZE = 20;

// State
let trendsChart = null;
let currentPage = 1;
let totalRequests = 0;
let filterType = '';
let filterCategory = '';
let filterTime = '';

// Initialize dashboard
document.addEventListener('DOMContentLoaded', () => {
    initDashboard();
    setInterval(refreshDashboard, REFRESH_INTERVAL);
});

async function initDashboard() {
    try {
        await refreshDashboard();
        initTrendsChart();
    } catch (error) {
        console.error('Failed to initialize dashboard:', error);
        showError('Failed to connect to server');
    }
}

async function refreshDashboard() {
    try {
        const data = await fetchAPI('/api/dashboard');
        updateStats(data.current_session);
        updateLatestRequest(data.latest_request);
        updateCategories(data.current_session);
        updateTrends(data.trends);
        updateInsights(data.insights);
        totalRequests = data.current_session.total_requests;
        await updateRecentRequests();
        await updateClaudeStats();
        await updateLearningTips();
    } catch (error) {
        console.error('Failed to refresh dashboard:', error);
    }
}

async function updateLearningTips() {
    try {
        const days = document.getElementById('tips-period').value;
        const data = await fetchAPI(`/api/learning-tips?days=${days}`);

        // Update stats summary
        const statsDiv = document.getElementById('tips-stats');
        if (data.stats) {
            statsDiv.innerHTML = `
                <div class="tips-stat">
                    <span class="tips-stat-value">${data.stats.total}</span>
                    <span class="tips-stat-label">Total Requests</span>
                </div>
                <div class="tips-stat">
                    <span class="tips-stat-value">${data.stats.avg_clarity}</span>
                    <span class="tips-stat-label">Avg Clarity</span>
                </div>
                <div class="tips-stat">
                    <span class="tips-stat-value">${data.stats.avg_quality}</span>
                    <span class="tips-stat-label">Avg Quality</span>
                </div>
                <div class="tips-stat optimal">
                    <span class="tips-stat-value">${data.stats.optimal_count || 0}</span>
                    <span class="tips-stat-label">Optimal</span>
                </div>
                <div class="tips-stat problem">
                    <span class="tips-stat-value">${data.stats.problem_count || 0}</span>
                    <span class="tips-stat-label">Problem</span>
                </div>
            `;
        }

        // Update tips list
        const tipsDiv = document.getElementById('tips-list');
        if (!data.tips || data.tips.length === 0) {
            tipsDiv.innerHTML = '<p class="no-data">Pas encore de tips. Continue à utiliser le monitor!</p>';
            return;
        }

        tipsDiv.innerHTML = data.tips.map(tip => {
            const icon = getTipIcon(tip.type);
            const countBadge = tip.count ? `<span class="tip-count">${tip.count}x</span>` : '';
            return `
                <div class="tip-item tip-${tip.type}">
                    <span class="tip-icon">${icon}</span>
                    <span class="tip-text">${escapeHtml(tip.text)}</span>
                    ${countBadge}
                </div>
            `;
        }).join('');
    } catch (error) {
        console.error('Failed to fetch learning tips:', error);
        document.getElementById('tips-list').innerHTML = '<p class="no-data">Error loading tips</p>';
    }
}

function getTipIcon(type) {
    const icons = {
        'success': '✅',
        'warning': '⚠️',
        'alert': '🚨',
        'pattern': '🔄',
        'tip': '💡',
        'info': 'ℹ️'
    };
    return icons[type] || '📝';
}

async function updateClaudeStats() {
    try {
        const data = await fetchAPI('/api/claude-stats');

        if (!data.found) {
            document.getElementById('claude-session-id').textContent = 'No Claude session found';
            return;
        }

        document.getElementById('claude-input-tokens').textContent = formatNumber(data.input_tokens);
        document.getElementById('claude-output-tokens').textContent = formatNumber(data.output_tokens);
        document.getElementById('claude-cache-read').textContent = formatNumber(data.cache_read_tokens);
        document.getElementById('claude-cache-write').textContent = formatNumber(data.cache_creation_tokens);
        document.getElementById('claude-total-tokens').textContent = formatNumber(data.total_tokens);
        document.getElementById('claude-estimated-cost').textContent = `$${data.estimated_cost_usd.toFixed(2)}`;
        document.getElementById('claude-session-id').textContent = `Session: ${data.session_id.slice(0, 20)}...`;
    } catch (error) {
        console.error('Failed to fetch Claude stats:', error);
        document.getElementById('claude-session-id').textContent = 'Error loading stats';
    }
}

// API Helper
async function fetchAPI(endpoint) {
    const response = await fetch(`${API_BASE}${endpoint}`);
    if (!response.ok) {
        throw new Error(`API error: ${response.status}`);
    }
    return response.json();
}

// Update Functions
function updateStats(stats) {
    document.getElementById('session-id').textContent = `Session: ${stats.session_id.slice(0, 25)}...`;
    document.getElementById('total-requests').textContent = stats.total_requests;
    const totalTokens = (stats.total_prompt_tokens || 0) + (stats.total_response_tokens || 0);
    document.getElementById('total-tokens').textContent = formatNumber(totalTokens);
    document.getElementById('avg-clarity').textContent = Math.round(stats.avg_prompt_clarity);
    document.getElementById('avg-quality').textContent = Math.round(stats.avg_response_quality);
    document.getElementById('avg-alignment').textContent = Math.round(stats.avg_alignment);
}

function formatNumber(num) {
    if (num >= 1000000) return (num / 1000000).toFixed(1) + 'M';
    if (num >= 1000) return (num / 1000).toFixed(1) + 'K';
    return num.toString();
}

function updateLatestRequest(request) {
    const container = document.getElementById('latest-request-content');

    if (!request) {
        container.innerHTML = '<p class="no-data">No requests yet</p>';
        return;
    }

    const clarityClass = getScoreClass(request.prompt_clarity_score);
    const qualityClass = getScoreClass(request.response_quality_score);
    const alignmentClass = getScoreClass(request.alignment_score);

    container.innerHTML = `
        <div class="request-detail">
            <span class="label">Prompt</span>
            <span class="value clickable" onclick="showRequestDetail(${request.id})">${escapeHtml(truncate(request.prompt_text, 150))}</span>
        </div>

        <div class="score-bars">
            <div class="score-item">
                <span class="score-label">Clarity</span>
                <div class="score-bar">
                    <div class="score-fill ${clarityClass}" style="width: ${request.prompt_clarity_score}%"></div>
                </div>
                <span class="score-value">${request.prompt_clarity_score}</span>
            </div>
            <div class="score-item">
                <span class="score-label">Quality</span>
                <div class="score-bar">
                    <div class="score-fill ${qualityClass}" style="width: ${request.response_quality_score}%"></div>
                </div>
                <span class="score-value">${request.response_quality_score}</span>
            </div>
            <div class="score-item">
                <span class="score-label">Alignment</span>
                <div class="score-bar">
                    <div class="score-fill ${alignmentClass}" style="width: ${request.alignment_score}%"></div>
                </div>
                <span class="score-value">${request.alignment_score}</span>
            </div>
        </div>

        <div class="request-detail">
            <span class="label">Category</span>
            <span class="category-badge ${request.alignment_category}">${request.alignment_category.toUpperCase()}</span>
        </div>

        <div class="suggestion-box">
            <span class="icon">💡</span>
            ${escapeHtml(request.suggestion)}
        </div>
    `;
}

function updateCategories(stats) {
    const total = stats.total_requests || 1;

    const categories = [
        { id: 'optimal', count: stats.optimal_count },
        { id: 'impressive', count: stats.impressive_count },
        { id: 'problem', count: stats.problem_count },
        { id: 'expected', count: stats.expected_count },
    ];

    categories.forEach(cat => {
        const pct = (cat.count / total) * 100;
        document.getElementById(`bar-${cat.id}`).style.width = `${pct}%`;
        document.getElementById(`count-${cat.id}`).textContent = cat.count;
    });
}

function initTrendsChart() {
    const ctx = document.getElementById('trends-chart').getContext('2d');

    trendsChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: [],
            datasets: [
                {
                    label: 'Clarity',
                    data: [],
                    borderColor: '#00ff88',
                    backgroundColor: 'rgba(0, 255, 136, 0.1)',
                    tension: 0.4,
                    fill: true,
                },
                {
                    label: 'Quality',
                    data: [],
                    borderColor: '#00d4ff',
                    backgroundColor: 'rgba(0, 212, 255, 0.1)',
                    tension: 0.4,
                    fill: true,
                },
                {
                    label: 'Alignment',
                    data: [],
                    borderColor: '#7b2cbf',
                    backgroundColor: 'rgba(123, 44, 191, 0.1)',
                    tension: 0.4,
                    fill: true,
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'top',
                    labels: {
                        color: '#888',
                        usePointStyle: true,
                    }
                }
            },
            scales: {
                x: {
                    grid: { color: 'rgba(255, 255, 255, 0.05)' },
                    ticks: { color: '#888' }
                },
                y: {
                    min: 0,
                    max: 100,
                    grid: { color: 'rgba(255, 255, 255, 0.05)' },
                    ticks: { color: '#888' }
                }
            }
        }
    });
}

function updateTrends(trends) {
    if (!trendsChart) return;

    trendsChart.data.labels = trends.dates;
    trendsChart.data.datasets[0].data = trends.prompt_clarity;
    trendsChart.data.datasets[1].data = trends.response_quality;
    trendsChart.data.datasets[2].data = trends.alignment;
    trendsChart.update();
}

function updateInsights(insights) {
    document.getElementById('clarity-trend').innerHTML =
        `Prompt clarity: <strong>${formatTrend(insights.clarity_trend)}</strong> vs last period`;

    const suggestionsContainer = document.getElementById('suggestions');
    if (insights.top_suggestions && insights.top_suggestions.length > 0) {
        suggestionsContainer.innerHTML = insights.top_suggestions
            .map(tip => `<div class="suggestion-tip">💡 ${escapeHtml(tip)}</div>`)
            .join('');
    } else {
        suggestionsContainer.innerHTML = '<div class="suggestion-tip">Great job! No improvements needed.</div>';
    }
}

async function updateRecentRequests() {
    try {
        const offset = (currentPage - 1) * PAGE_SIZE;
        let url = `/api/requests?limit=${PAGE_SIZE}&offset=${offset}`;
        if (filterType) url += `&type=${filterType}`;
        if (filterCategory) url += `&category=${filterCategory}`;
        if (filterTime) url += `&time=${filterTime}`;
        const requests = await fetchAPI(url);
        const tbody = document.getElementById('requests-tbody');

        if (requests.length === 0) {
            tbody.innerHTML = '<tr><td colspan="8" class="no-data">No requests yet</td></tr>';
            return;
        }

        tbody.innerHTML = requests.map(req => `
            <tr class="clickable-row" onclick="showRequestDetail(${req.id})">
                <td>${formatTime(req.timestamp)}</td>
                <td class="col-prompt" title="Click for full text">${escapeHtml(truncate(req.prompt_text, 80))}</td>
                <td class="col-response" title="Click for full text">${escapeHtml(truncate(req.response_text, 80))}</td>
                <td><span class="score ${getScoreClass(req.prompt_clarity_score)}">${req.prompt_clarity_score}</span></td>
                <td><span class="score ${getScoreClass(req.response_quality_score)}">${req.response_quality_score}</span></td>
                <td><span class="score ${getScoreClass(req.alignment_score)}">${req.alignment_score}</span></td>
                <td><span class="category-badge ${req.alignment_category}">${req.alignment_category}</span></td>
                <td class="tokens-cell">${req.prompt_tokens + req.response_tokens}</td>
            </tr>
        `).join('');

        // Update pagination
        updatePagination();
    } catch (error) {
        console.error('Failed to fetch requests:', error);
    }
}

function updatePagination() {
    const totalPages = Math.ceil(totalRequests / PAGE_SIZE) || 1;
    document.getElementById('page-info').textContent = `Page ${currentPage} / ${totalPages}`;
    document.getElementById('prev-page').disabled = currentPage <= 1;
    document.getElementById('next-page').disabled = currentPage >= totalPages;
}

function changePage(delta) {
    currentPage += delta;
    if (currentPage < 1) currentPage = 1;
    updateRecentRequests();
}

function applyFilters() {
    filterType = document.getElementById('filter-type').value;
    filterCategory = document.getElementById('filter-category').value;
    filterTime = document.getElementById('filter-time').value;
    currentPage = 1;
    updateRecentRequests();
}

// Request Detail Modal
function isToolCall(promptText) {
    // Tool calls start with [ToolName] but NOT [User]
    return promptText && promptText.startsWith('[') && !promptText.startsWith('[User]');
}

async function showRequestDetail(requestId) {
    try {
        const data = await fetchAPI(`/api/requests/${requestId}/detail`);

        document.getElementById('detail-id').textContent = `#${data.id}`;

        const efficiency = data.efficiency_percent;
        const efficiencyClass = efficiency >= 100 ? 'excellent' : efficiency >= 70 ? 'good' : 'poor';
        const isUserPrompt = !isToolCall(data.prompt_text);

        document.getElementById('detail-body').innerHTML = `
            <div class="detail-section">
                <h3>📝 ${isUserPrompt ? 'My Prompt' : 'Tool Call'}</h3>
                <div class="text-box prompt-box">${escapeHtml(data.prompt_text)}</div>
            </div>

            ${isUserPrompt ? `
            <div class="detail-section">
                <h3>📊 Clarity Analysis <span class="score-badge ${getScoreClass(data.clarity.score)}">${data.clarity.score}/100</span></h3>
                <div class="breakdown-grid">
                    ${renderBreakdown(data.clarity.breakdown)}
                </div>
            </div>

            <div class="detail-section improved-section">
                <h3>💡 Suggested Improved Prompt</h3>
                <div class="text-box improved-box">${escapeHtml(data.improved_prompt)}</div>
                <button class="copy-btn" onclick="copyText(\`${escapeHtml(data.improved_prompt).replace(/`/g, '\\`')}\`)">📋 Copy to Clipboard</button>
            </div>
            ` : ''}

            <div class="detail-section">
                <h3>🤖 AI Response</h3>
                <div class="text-box response-box">${escapeHtml(data.response_text)}</div>
            </div>

            ${isUserPrompt ? `
            <div class="detail-section">
                <h3>📊 Quality Analysis <span class="score-badge ${getScoreClass(data.quality.score)}">${data.quality.score}/100</span></h3>
                <div class="breakdown-grid">
                    ${renderQualityBreakdown(data.quality.breakdown)}
                </div>
            </div>
            ` : ''}

            <div class="detail-footer">
                <div class="efficiency-display ${efficiencyClass}">
                    <span class="efficiency-label">Efficiency</span>
                    <span class="efficiency-value">${efficiency}%</span>
                </div>
                <div class="meta-info">
                    <span class="category-badge large ${data.alignment_category}">${data.alignment_category.toUpperCase()}</span>
                    <span class="meta-item">Tokens: ${data.prompt_tokens + data.response_tokens}</span>
                </div>
            </div>

            ${isUserPrompt && data.suggestion ? `
            <div class="detail-section suggestion-section">
                <div class="suggestion-box large">
                    <span class="icon">💡</span>
                    ${escapeHtml(data.suggestion)}
                </div>
            </div>
            ` : ''}
        `;

        document.getElementById('detail-modal').style.display = 'flex';
    } catch (error) {
        console.error('Failed to load request detail:', error);
        alert('Failed to load request details');
    }
}

function renderBreakdown(breakdown) {
    const items = [
        { name: 'Length', key: 'length', tip: 'Optimal: 50-500 chars' },
        { name: 'Context', key: 'context', tip: 'Add "Given that..."' },
        { name: 'Specificity', key: 'specificity', tip: 'Clear question' },
        { name: 'Examples', key: 'examples', tip: 'Include code samples' },
        { name: 'Constraints', key: 'constraints', tip: 'Use "must", "should"' },
    ];

    return items.map(item => {
        const score = breakdown[item.key].score;
        const max = breakdown[item.key].max;
        const pct = (score / max) * 100;
        const status = pct >= 70 ? 'good' : pct >= 40 ? 'partial' : 'missing';

        return `
            <div class="breakdown-item ${status}">
                <span class="breakdown-name">${item.name}</span>
                <div class="breakdown-bar">
                    <div class="breakdown-fill" style="width: ${pct}%"></div>
                </div>
                <span class="breakdown-score">${score}/${max}</span>
                ${status === 'missing' ? `<span class="breakdown-tip">${item.tip}</span>` : ''}
            </div>
        `;
    }).join('');
}

function renderQualityBreakdown(breakdown) {
    const items = [
        { name: 'Completeness', key: 'completeness' },
        { name: 'Structure', key: 'structure' },
        { name: 'Concreteness', key: 'concreteness' },
        { name: 'Vagueness', key: 'vagueness_penalty' },
    ];

    return items.map(item => {
        const score = breakdown[item.key].score;
        const max = breakdown[item.key].max;
        const isVagueness = item.key === 'vagueness_penalty';
        const pct = isVagueness ? Math.abs(score) * 4 : (score / max) * 100;
        const status = isVagueness ? (score < 0 ? 'missing' : 'good') : (pct >= 70 ? 'good' : pct >= 40 ? 'partial' : 'missing');

        return `
            <div class="breakdown-item ${status}">
                <span class="breakdown-name">${item.name}</span>
                <div class="breakdown-bar">
                    <div class="breakdown-fill" style="width: ${Math.min(100, pct)}%"></div>
                </div>
                <span class="breakdown-score">${score}/${max}</span>
            </div>
        `;
    }).join('');
}

function closeDetailModal() {
    document.getElementById('detail-modal').style.display = 'none';
}

// Reset Modal
function showResetConfirm() {
    document.getElementById('reset-modal').style.display = 'flex';
}

function closeResetModal() {
    document.getElementById('reset-modal').style.display = 'none';
}

async function confirmReset() {
    try {
        const response = await fetch('/api/reset?confirm=true', { method: 'DELETE' });
        const data = await response.json();

        if (data.status === 'success') {
            closeResetModal();
            currentPage = 1;
            filterType = '';
            filterCategory = '';
            filterTime = '';
            document.getElementById('filter-type').value = '';
            document.getElementById('filter-category').value = '';
            document.getElementById('filter-time').value = '';
            await refreshDashboard();
            showNotification('All data has been reset!', 'success');
        } else {
            showNotification('Failed to reset: ' + (data.message || 'Unknown error'), 'error');
        }
    } catch (error) {
        console.error('Reset failed:', error);
        showNotification('Failed to reset data', 'error');
    }
}

// Utility Functions
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;
    document.body.appendChild(notification);

    setTimeout(() => notification.classList.add('show'), 10);
    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}

function copyText(text) {
    navigator.clipboard.writeText(text).then(() => {
        showNotification('Copied to clipboard!', 'success');
    }).catch(err => {
        console.error('Failed to copy:', err);
    });
}

function getScoreClass(score) {
    if (score >= 70) return 'high';
    if (score >= 40) return 'medium';
    return 'low';
}

function truncate(text, length) {
    if (!text) return '';
    if (text.length <= length) return text;
    return text.slice(0, length) + '...';
}

function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function formatTrend(value) {
    if (value > 0) return `<span style="color: #00ff88">+${value.toFixed(1)}%</span>`;
    if (value < 0) return `<span style="color: #ff4444">${value.toFixed(1)}%</span>`;
    return `<span style="color: #888">0%</span>`;
}

function formatTime(timestamp) {
    const date = new Date(timestamp);
    const now = new Date();
    const diff = (now - date) / 1000;

    // Format dd/mm/YYYY H:m for times < 1h
    if (diff < 3600) {
        const day = String(date.getDate()).padStart(2, '0');
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const year = date.getFullYear();
        const hours = date.getHours();
        const minutes = date.getMinutes();
        return `${day}/${month}/${year} ${hours}:${String(minutes).padStart(2, '0')}`;
    }

    // Relative time for >= 1h
    if (diff < 86400) return `${Math.floor(diff / 3600)}h ago`;
    if (diff < 604800) return `${Math.floor(diff / 86400)}d ago`;
    return `${Math.floor(diff / 604800)}w ago`;
}

function showError(message) {
    document.getElementById('status-badge').textContent = 'Offline';
    document.getElementById('status-badge').style.background = '#ff4444';
    console.error(message);
}

// Close modals on escape key
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        closeDetailModal();
        closeResetModal();
    }
});

// Close modals on overlay click
document.querySelectorAll('.modal-overlay').forEach(modal => {
    modal.addEventListener('click', (e) => {
        if (e.target === modal) {
            closeDetailModal();
            closeResetModal();
        }
    });
});
