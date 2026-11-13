/**
 * script.js – Interactive Features for Qaisar Abbas's Portfolio
 * Developer: Qaisar Abbas
 */

document.addEventListener('DOMContentLoaded', () => {
  // ------------------------------------------------------------------------
  // 1. Theme Toggle (Dark / Light Mode)
  // ------------------------------------------------------------------------
  const themeToggle = document.getElementById('theme-toggle');
  const root = document.documentElement;

  // Check saved theme or system preference
  const savedTheme = localStorage.getItem('portfolio-theme');
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  const initialTheme = savedTheme || (prefersDark ? 'dark' : 'dark'); // Default to dark

  setTheme(initialTheme);

  if (themeToggle) {
    themeToggle.addEventListener('click', () => {
      const currentTheme = root.getAttribute('data-theme') || 'dark';
      const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
      setTheme(newTheme);
      showToast(`Switched to ${newTheme} theme`);
    });
  }

  function setTheme(theme) {
    root.setAttribute('data-theme', theme);
    localStorage.setItem('portfolio-theme', theme);
    if (themeToggle) {
      themeToggle.setAttribute('aria-label', `Switch to ${theme === 'dark' ? 'light' : 'dark'} mode`);
    }
  }

  // ------------------------------------------------------------------------
  // 2. Mobile Burger Navigation Menu
  // ------------------------------------------------------------------------
  const burger = document.getElementById('burger');
  const nav = document.getElementById('nav');
  const navLinks = document.querySelectorAll('.nav-link');

  if (burger && nav) {
    burger.addEventListener('click', (e) => {
      e.stopPropagation();
      const isOpen = nav.classList.contains('open');
      toggleMenu(!isOpen);
    });

    // Close mobile menu when clicking any nav link
    navLinks.forEach(link => {
      link.addEventListener('click', () => {
        if (nav.classList.contains('open')) {
          toggleMenu(false);
        }
      });
    });

    // Close when clicking outside
    document.addEventListener('click', (e) => {
      if (nav.classList.contains('open') && !nav.contains(e.target) && !burger.contains(e.target)) {
        toggleMenu(false);
      }
    });
  }

  function toggleMenu(open) {
    if (burger && nav) {
      burger.classList.toggle('open', open);
      burger.setAttribute('aria-expanded', String(open));
      nav.classList.toggle('open', open);
    }
  }

  // ------------------------------------------------------------------------
  // 3. Hero Section Typing Effect / Role Rotator
  // ------------------------------------------------------------------------
  const typingElement = document.getElementById('typing-text');
  if (typingElement) {
    const roles = [
      'Business Central (AL) Developer',
      'Microsoft Certified ERP Consultant',
      'AL Extension Architect',
      'Software Engineering Specialist',
      'Cybersecurity Defense Analyst',
      'WordPress Solutions Developer'
    ];

    let roleIndex = 0;
    let charIndex = 0;
    let isDeleting = false;
    let typingDelay = 90;
    const pauseEnd = 2000;
    const pauseStart = 400;

    function typeLoop() {
      const currentRole = roles[roleIndex];

      if (isDeleting) {
        typingElement.textContent = currentRole.substring(0, charIndex - 1);
        charIndex--;
        typingDelay = 45;
      } else {
        typingElement.textContent = currentRole.substring(0, charIndex + 1);
        charIndex++;
        typingDelay = 90;
      }

      if (!isDeleting && charIndex === currentRole.length) {
        typingDelay = pauseEnd;
        isDeleting = true;
      } else if (isDeleting && charIndex === 0) {
        isDeleting = false;
        roleIndex = (roleIndex + 1) % roles.length;
        typingDelay = pauseStart;
      }

      setTimeout(typeLoop, typingDelay);
    }

    typeLoop();
  }

  // ------------------------------------------------------------------------
  // 4. Scroll Active Navigation Link Tracker (ScrollSpy)
  // ------------------------------------------------------------------------
  const sections = document.querySelectorAll('section[id]');

  function updateActiveNav() {
    const scrollPos = window.scrollY + 120;

    sections.forEach(section => {
      const top = section.offsetTop;
      const height = section.offsetHeight;
      const id = section.getAttribute('id');

      if (scrollPos >= top && scrollPos < top + height) {
        navLinks.forEach(link => {
          link.classList.remove('active');
          if (link.getAttribute('href') === `#${id}`) {
            link.classList.add('active');
          }
        });
      }
    });
  }

  window.addEventListener('scroll', updateActiveNav, { passive: true });
  updateActiveNav();

  // ------------------------------------------------------------------------
  // 5. Scroll Reveal Animations (IntersectionObserver)
  // ------------------------------------------------------------------------
  const revealTargets = document.querySelectorAll(
    '.about-card, .cert-card, .exp-card, .project-card, .skill-category-card, .contact-info-panel, .contact-form-panel, .metric-card'
  );

  revealTargets.forEach(el => el.classList.add('reveal-init'));

  const revealObserver = new IntersectionObserver(
    (entries, obs) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('reveal-in');
          obs.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.12, rootMargin: '0px 0px -40px 0px' }
  );

  revealTargets.forEach(el => revealObserver.observe(el));

  // ------------------------------------------------------------------------
  // 6. Metric Numbers Counter Animation
  // ------------------------------------------------------------------------
  const metricCards = document.querySelectorAll('.metric-card');
  let metricsAnimated = false;

  const metricObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting && !metricsAnimated) {
        metricsAnimated = true;
        animateMetrics();
      }
    });
  }, { threshold: 0.4 });

  const metricsGrid = document.querySelector('.metrics-grid');
  if (metricsGrid) {
    metricObserver.observe(metricsGrid);
  }

  function animateMetrics() {
    metricCards.forEach(card => {
      const numEl = card.querySelector('.metric-num');
      if (!numEl) return;
      const targetStr = numEl.getAttribute('data-target') || '0';
      const target = parseInt(targetStr, 10);
      const originalText = numEl.textContent;
      const hasPlus = originalText.includes('+');
      const hasPercent = originalText.includes('%');

      let current = 0;
      const step = Math.max(1, Math.floor(target / 30));
      const interval = setInterval(() => {
        current += step;
        if (current >= target) {
          current = target;
          clearInterval(interval);
          numEl.textContent = `${current}${hasPlus ? '+' : ''}${hasPercent ? '%' : ''}`;
        } else {
          numEl.textContent = `${current}${hasPlus ? '+' : ''}${hasPercent ? '%' : ''}`;
        }
      }, 35);
    });
  }

  // ------------------------------------------------------------------------
  // 7. Project Category Filters
  // ------------------------------------------------------------------------
  const filterBtns = document.querySelectorAll('.filter-btn');
  const projectCards = document.querySelectorAll('.project-card');

  filterBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      filterBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      const filter = btn.getAttribute('data-filter');

      projectCards.forEach(card => {
        const cat = card.getAttribute('data-category');
        if (filter === 'all' || cat === filter) {
          card.style.display = 'flex';
          setTimeout(() => {
            card.style.opacity = '1';
            card.style.transform = 'translateY(0)';
          }, 20);
        } else {
          card.style.opacity = '0';
          card.style.transform = 'translateY(12px)';
          setTimeout(() => {
            card.style.display = 'none';
          }, 200);
        }
      });
    });
  });

  // ------------------------------------------------------------------------
  // 8. Contact Form Handling & Validation
  // ------------------------------------------------------------------------
  const contactForm = document.getElementById('contact-form');
  const submitBtn = document.getElementById('submit-btn');
  const formFeedback = document.getElementById('form-feedback');

  if (contactForm) {
    contactForm.addEventListener('submit', (e) => {
      e.preventDefault();

      const nameInput = document.getElementById('name');
      const emailInput = document.getElementById('email');
      const subjectInput = document.getElementById('subject');
      const messageInput = document.getElementById('message');

      let isValid = true;

      // Validate Name
      if (!nameInput.value.trim()) {
        setError(nameInput, true);
        isValid = false;
      } else {
        setError(nameInput, false);
      }

      // Validate Email
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailInput.value.trim() || !emailRegex.test(emailInput.value.trim())) {
        setError(emailInput, true);
        isValid = false;
      } else {
        setError(emailInput, false);
      }

      // Validate Subject
      if (!subjectInput.value) {
        setError(subjectInput, true);
        isValid = false;
      } else {
        setError(subjectInput, false);
      }

      // Validate Message
      if (!messageInput.value.trim()) {
        setError(messageInput, true);
        isValid = false;
      } else {
        setError(messageInput, false);
      }

      if (!isValid) return;

      // Simulated Submission with mailto fallback
      submitBtn.classList.add('loading');
      submitBtn.disabled = true;

      setTimeout(() => {
        submitBtn.classList.remove('loading');
        submitBtn.disabled = false;

        formFeedback.className = 'form-feedback success';
        formFeedback.textContent = `Thank you, ${nameInput.value.trim()}! Your message has been prepared. Opening your email client...`;
        formFeedback.style.display = 'block';

        showToast('Message submitted successfully!');

        // Trigger mailto client as standard static site fallback
        const mailtoUrl = `mailto:Qaisarsmr101@gmail.com?subject=${encodeURIComponent(
          subjectInput.value + ' - Inquiry from ' + nameInput.value
        )}&body=${encodeURIComponent(
          `Name: ${nameInput.value}\nEmail: ${emailInput.value}\nSubject: ${subjectInput.value}\n\nMessage:\n${messageInput.value}`
        )}`;

        setTimeout(() => {
          window.location.href = mailtoUrl;
        }, 800);

        contactForm.reset();
      }, 1000);
    });

    // Clear error on input
    ['name', 'email', 'subject', 'message'].forEach(id => {
      const el = document.getElementById(id);
      if (el) {
        el.addEventListener('input', () => setError(el, false));
        el.addEventListener('change', () => setError(el, false));
      }
    });
  }

  function setError(inputEl, isError) {
    const parent = inputEl.closest('.form-group');
    if (parent) {
      parent.classList.toggle('has-error', isError);
    }
  }

  // ------------------------------------------------------------------------
  // 9. Copy Email to Clipboard
  // ------------------------------------------------------------------------
  const copyBtn = document.getElementById('copy-email-btn');
  if (copyBtn) {
    copyBtn.addEventListener('click', () => {
      const email = 'Qaisarsmr101@gmail.com';
      navigator.clipboard.writeText(email).then(() => {
        showToast('Email copied to clipboard!');
      }).catch(() => {
        // Fallback for older browsers
        const temp = document.createElement('textarea');
        temp.value = email;
        document.body.appendChild(temp);
        temp.select();
        document.execCommand('copy');
        document.body.removeChild(temp);
        showToast('Email copied to clipboard!');
      });
    });
  }

  // ------------------------------------------------------------------------
  // 10. Back to Top Button
  // ------------------------------------------------------------------------
  const backToTopBtn = document.getElementById('back-to-top');
  if (backToTopBtn) {
    window.addEventListener('scroll', () => {
      if (window.scrollY > 350) {
        backToTopBtn.classList.add('visible');
      } else {
        backToTopBtn.classList.remove('visible');
      }
    }, { passive: true });

    backToTopBtn.addEventListener('click', () => {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  }

  // ------------------------------------------------------------------------
  // 11. Toast Notification Helper
  // ------------------------------------------------------------------------
  function showToast(message) {
    const container = document.getElementById('toast-container');
    if (!container) return;

    const toast = document.createElement('div');
    toast.className = 'toast';
    toast.textContent = message;

    container.appendChild(toast);

    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transform = 'translateY(10px)';
      toast.style.transition = 'all 0.3s ease';
      setTimeout(() => toast.remove(), 300);
    }, 2800);
  }
});
