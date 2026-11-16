<script setup>
const name = 'Your Name'
const role = 'Full-Stack Developer'

const skills = ['Vue', 'JavaScript', 'PHP', 'Laravel', 'Python', 'SQL']

const projects = [
  { title: 'Project One', description: 'Short description of the first project.', link: '#' },
  { title: 'Project Two', description: 'Short description of the second project.', link: '#' },
  { title: 'Project Three', description: 'Short description of the third project.', link: '#' },
]
</script>

<template>
  <header class="nav">
    <div class="container nav-inner">
      <strong>{{ name }}</strong>
      <nav>
        <a href="#about">About</a>
        <a href="#projects">Projects</a>
        <a href="#contact">Contact</a>
      </nav>
    </div>
  </header>

  <main>
    <section class="hero">
      <div class="container">
        <h1>Hi, I'm {{ name }}</h1>
        <p>{{ role }}</p>
      </div>
    </section>

    <section id="about">
      <div class="container">
        <h2>About</h2>
        <p>A few lines about who you are, what you do and what you enjoy building.</p>
        <ul class="skills">
          <li v-for="skill in skills" :key="skill">{{ skill }}</li>
        </ul>
      </div>
    </section>

    <section id="projects" class="alt">
      <div class="container">
        <h2>Projects</h2>
        <div class="grid">
          <article v-for="project in projects" :key="project.title" class="card">
            <h3>{{ project.title }}</h3>
            <p>{{ project.description }}</p>
            <a :href="project.link">View →</a>
          </article>
        </div>
      </div>
    </section>

    <section id="contact">
      <div class="container">
        <h2>Contact</h2>
        <p>Email: <a href="mailto:hello@example.com">hello@example.com</a></p>
      </div>
    </section>
  </main>

  <footer class="footer">
    <div class="container">© {{ new Date().getFullYear() }} {{ name }}</div>
  </footer>
</template>

<style scoped>
.nav { background: #fff; border-bottom: 1px solid #e5e7eb; position: sticky; top: 0; }
.nav-inner { display: flex; justify-content: space-between; align-items: center; height: 56px; }
.nav nav a { margin-left: 20px; color: #374151; }
.hero { background: #111827; color: #fff; padding: 96px 0; }
.hero h1 { font-size: 2.5rem; }
.hero p { font-size: 1.25rem; color: #9ca3af; }
.skills { list-style: none; display: flex; flex-wrap: wrap; gap: 8px; margin-top: 16px; }
.skills li { background: #e0e7ff; color: #3730a3; padding: 4px 12px; border-radius: 999px; font-size: 0.9rem; }
.alt { background: #fff; }
.grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 16px; }
.card { border: 1px solid #e5e7eb; border-radius: 8px; padding: 20px; background: #f9fafb; }
.card h3 { margin-bottom: 8px; }
.card p { margin-bottom: 12px; color: #4b5563; }
.footer { text-align: center; padding: 24px 0; color: #6b7280; border-top: 1px solid #e5e7eb; }
</style>
