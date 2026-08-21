import en from './en.json';
import de from './de.json';

const translations = {
  en,
  de,
};

export function useTranslations(lang: 'en' | 'de') {
  return function t(key: keyof typeof en) {
    return translations[lang][key] || translations['en'][key];
  }
}
