import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        background: "#13212e",
        navy: {
          light: "#2b5b84", 
          dark: "#1e415e",
        },
        gold: {
          light: "#ffec13",
          DEFAULT: "#ffd43b",
        },
        slate: {
          950: "#0c141d",
        }
      },
      fontFamily: {
        sans: ["Source Sans Pro", "Inter", "sans-serif"],
        mono: ["Source Code Pro", "monospace"],
      },
    },
  },
  plugins: [],
};
export default config;
