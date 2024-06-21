import { defineConfig } from "vocs";

export default defineConfig({
  title: "Bloks",
  baseUrl: "https://bloks.sh",
  titleTemplate: "%s · Bloks",
  description:
    "Build onchain products faster with a modular Solidity framework.",
  iconUrl: { light: "/favicons/light.png", dark: "/favicons/dark.png" },
  logoUrl: { light: "/icon-light.png", dark: "/icon-dark.png" },
  theme: {
    accentColor: {
      light: "#121212",
      dark: "#fafafa",
    },
    variables: {
      color: {
        background: {
          light: "#EDECEC",
          dark: "#222222",
        },
        border: {
          light: "#EEEEEE",
          dark: "#333333",
        },
      },
    },
  },
  topNav: [{ text: "Docs", link: "/guides/quickstart", match: "/docs" }],
  socials: [
    {
      icon: "github",
      link: "https://github.com/ilikesymmetry/bloks",
    },
    {
      icon: "x",
      link: "https://x.com/ilikesymmetry",
    },
  ],
  sidebar: [
    {
      text: "Introduction",
      collapsed: false,
      items: [
        {
          text: "Why Blocks",
          link: "/introduction/why-bloks",
        },
        {
          text: "Architecture",
          link: "/introduction/architecture",
        },
      ],
    },
    {
      text: "Guides",
      collapsed: false,
      items: [
        {
          text: "Quickstart",
          link: "/guides/quickstart",
        },
      ],
    },
  ],
});
