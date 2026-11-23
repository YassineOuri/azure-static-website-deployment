<script setup>
import { ref, onMounted } from 'vue'

const name = 'Yassine Ouri'
const role = 'Full-Stack Developer'
const intro = 'I design and build reliable web applications, from database to interface.'
const email = 'hello@example.com'
const visits = ref(null)

const skillGroups = [
  { label: 'Frontend', items: ['Vue', 'JavaScript'] },
  { label: 'Backend', items: ['PHP', 'Laravel', 'Python'] },
  { label: 'Data', items: ['SQL'] },
]

const projects = [
  { title: 'Project One', description: 'Short description of the first project.', stack: ['Vue', 'Laravel'], link: '#' },
  { title: 'Project Two', description: 'Short description of the second project.', stack: ['Python', 'SQL'], link: '#' },
  { title: 'Project Three', description: 'Short description of the third project.', stack: ['JavaScript', 'PHP'], link: '#' },
]

onMounted(async () => {
  try {
    const response = await fetch(
      ' https://func-mos6keloe4inq.azurewebsites.net/api/visits'
    )
    if (!response.ok) throw new Error(`HTTP ${response.status}`)
    const json = await response.json()
    visits.value = json.count
  } catch (err) {
    console.error('Failed to load visits:', err)
  }
})
</script>

<template>
  <header class="nav">
    <div class="container nav-inner">
      <a href="#top" class="brand">{{ name }}</a>
      <nav aria-label="Primary">
        <a href="#about">About</a>
        <a href="#projects">Projects</a>
        <a href="#contact">Contact</a>
      </nav>
    </div>
  </header>

  <main id="top">
    <section class="hero">
      <div class="container hero-grid">
        <div>
          <h1>{{ name }}</h1>
          <p class="role">{{ role }}</p>
          <p class="intro">{{ intro }}</p>
          <div class="actions">
            <a href="#projects" class="btn btn-primary">View projects</a>
            <a href="#contact" class="btn btn-ghost">Get in touch</a>
          </div>
          <p class="visits">
            <span class="visits-dot" aria-hidden="true"></span>
            <span class="visits-label">Total visits</span>
            <span class="visits-count">{{ visits === null ? '—' : visits.toLocaleString() }}</span>
          </p>
        </div>

        <aside class="stack" aria-label="Technical skills">
          <h2>Stack</h2>
          <dl>
            <div v-for="group in skillGroups" :key="group.label" class="stack-row">
              <dt>{{ group.label }}</dt>
              <dd>
                <span v-for="item in group.items" :key="item" class="chip">{{ item }}</span>
              </dd>
            </div>
          </dl>
        </aside>
      </div>
    </section>

    <section id="about" class="section">
      <div class="container split">
        <h2>About</h2>
        <p>
          A few lines about who you are, what you do and what you enjoy building.
          Mention the kind of teams you work with and the problems you like to solve.
        </p>
      </div>
    </section>

    <section id="projects" class="section section-surface">
      <div class="container split">
        <h2>Selected projects</h2>
        <ul class="projects">
          <li v-for="project in projects" :key="project.title">
            <a :href="project.link" class="project">
              <div>
                <h3>{{ project.title }}</h3>
                <p>{{ project.description }}</p>
                <span class="tags">{{ project.stack.join(', ') }}</span>
              </div>
              <span class="arrow" aria-hidden="true">↗</span>
            </a>
          </li>
        </ul>
      </div>
    </section>

    <section id="contact" class="section">
      <div class="container split">
        <h2>Contact</h2>
        <div>
          <p class="contact-lead">Have a project in mind or want to talk about a role?</p>
          <a :href="`mailto:${email}`" class="email">{{ email }}</a>
        </div>
      </div>
    </section>
  </main>

  <footer class="footer">
    <div class="container">© {{ new Date().getFullYear() }} {{ name }}</div>
  </footer>
</template>

<style scoped>
/* Navigation */
.nav {
  position: sticky; top: 0; z-index: 10;
  background: rgba(245, 247, 250, 0.88);
  backdrop-filter: saturate(160%) blur(10px);
  border-bottom: 1px solid var(--line);
}
.nav-inner { display: flex; justify-content: space-between; align-items: center; height: 60px; }
.brand { font-weight: 600; letter-spacing: -0.01em; }
.nav nav { display: flex; gap: 28px; }
.nav nav a { font-size: 0.9rem; color: var(--muted); transition: color 0.15s; }
.nav nav a:hover { color: var(--ink); }

/* Hero */
.hero { padding: 96px 0 80px; }
.hero-grid { display: grid; grid-template-columns: 1.4fr 1fr; gap: 64px; align-items: center; }
h1 {
  font-family: var(--serif);
  font-weight: 500;
  font-size: clamp(2.75rem, 6vw, 4.5rem);
  line-height: 1.05;
  letter-spacing: -0.02em;
}
.role { margin-top: 16px; font-size: 1.25rem; color: var(--accent); font-weight: 500; }
.intro { margin-top: 20px; max-width: 46ch; font-size: 1.1rem; color: var(--muted); }
.actions { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 36px; }

.btn {
  display: inline-block; padding: 12px 22px; border-radius: 6px;
  font-size: 0.95rem; font-weight: 500;
  transition: background 0.15s, border-color 0.15s;
}
.btn-primary { background: var(--ink); color: #fff; }
.btn-primary:hover { background: var(--accent); }
.btn-ghost { border: 1px solid var(--line); background: var(--surface); }
.btn-ghost:hover { border-color: var(--ink); }

/* Stack panel */
.stack { background: var(--surface); border: 1px solid var(--line); border-radius: 12px; padding: 28px; }
.stack h2 { font-size: 1rem; font-weight: 600; margin-bottom: 8px; }
.stack-row { display: grid; grid-template-columns: 88px 1fr; gap: 12px; padding: 14px 0; border-top: 1px solid var(--line); }
.stack-row:first-child { border-top: 0; }
.stack dt { font-size: 0.9rem; color: var(--muted); padding-top: 3px; }
.stack dd { display: flex; flex-wrap: wrap; gap: 8px; }
.chip { background: var(--accent-soft); color: var(--accent); padding: 3px 12px; border-radius: 999px; font-size: 0.875rem; font-weight: 500; }

/* Sections */
.section { padding: 88px 0; }
.section-surface { background: var(--surface); border-block: 1px solid var(--line); }
.split { display: grid; grid-template-columns: 200px 1fr; gap: 48px; }
.split h2 { font-family: var(--serif); font-weight: 500; font-size: 1.75rem; letter-spacing: -0.01em; line-height: 1.2; }
#about .split > p { max-width: 62ch; font-size: 1.1rem; color: var(--muted); }

/* Projects */
.projects { list-style: none; }
.projects li + li { border-top: 1px solid var(--line); }
.project { display: flex; justify-content: space-between; gap: 24px; padding: 28px 0; }
.projects li:first-child .project { padding-top: 0; }
.project h3 { font-size: 1.15rem; font-weight: 600; letter-spacing: -0.01em; transition: color 0.15s; }
.project p { margin-top: 6px; max-width: 56ch; color: var(--muted); }
.tags { display: block; margin-top: 10px; font-size: 0.875rem; color: var(--accent); font-weight: 500; }
.arrow { font-size: 1.25rem; color: var(--muted); transition: transform 0.2s, color 0.2s; }
.project:hover h3, .project:hover .arrow { color: var(--accent); }
.project:hover .arrow { transform: translate(3px, -3px); }

/* Contact */
.contact-lead { color: var(--muted); font-size: 1.1rem; }
.email {
  display: inline-block; margin-top: 8px;
  font-family: var(--serif); font-size: clamp(1.5rem, 3.5vw, 2.25rem);
  border-bottom: 1px solid var(--line); transition: border-color 0.15s, color 0.15s;
}
.email:hover { color: var(--accent); border-color: var(--accent); }

/* Footer */
.footer { padding: 28px 0; border-top: 1px solid var(--line); font-size: 0.875rem; color: var(--muted); }

/* Visit counter */
.visits {
  display: inline-flex; align-items: center; gap: 10px;
  margin-top: 28px; padding: 6px 8px 6px 14px;
  background: var(--surface); border: 1px solid var(--line); border-radius: 999px;
  font-size: 0.875rem;
}
.visits-dot { width: 8px; height: 8px; border-radius: 50%; background: var(--accent); }
.visits-label { color: var(--muted); }
.visits-count {
  background: var(--accent-soft); color: var(--accent);
  padding: 2px 12px; border-radius: 999px;
  font-weight: 500; font-variant-numeric: tabular-nums;
}

/* Responsive */
@media (max-width: 800px) {
  .hero { padding: 56px 0 48px; }
  .hero-grid, .split { grid-template-columns: 1fr; gap: 32px; }
  .section { padding: 56px 0; }
  .nav nav { gap: 18px; }
}
</style>