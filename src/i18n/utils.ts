import en from './en.json';

const translations = {
  en,
};

export function useTranslations(lang: 'en') {
  return function t(key: keyof typeof en) {
    return translations[lang][key] || translations['en'][key];
  }
}
