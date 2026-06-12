<template>
  <section class="hero">
    <div class="hero-overlay">
      <h1>美味佳肴，送到您手中</h1>
      <p>从我们丰富的菜品中选择您喜爱的美食，在家享受美味的午餐或晚餐。</p>
      <p class="hero-sub">所有菜品均采用优质食材，准时配送，由经验丰富的厨师精心烹制！</p>
    </div>
  </section>
</template>

<style scoped>
.hero {
  background: linear-gradient(rgba(0,0,0,0.55), rgba(0,0,0,0.55)),
              url('https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200&q=80') center/cover no-repeat;
  min-height: 340px;
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
  padding: 60px 20px;
}

.hero-overlay {
  max-width: 650px;
  color: var(--color-text-white);
}

.hero-overlay h1 {
  font-size: 36px;
  font-weight: 700;
  margin-bottom: 16px;
  line-height: 1.2;
}

.hero-overlay p {
  font-size: 16px;
  line-height: 1.7;
  opacity: 0.95;
  margin-bottom: 8px;
}

.hero-sub {
  font-size: 14px !important;
  opacity: 0.8 !important;
}
</style>
