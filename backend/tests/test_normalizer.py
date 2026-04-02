"""Unit tests for the Turkish text normalizer (normalize_name function).

Tests cover all 12 Turkish diacritical characters (6 lowercase + 6 uppercase),
whitespace collapsing, trimming, and real product name examples.
"""
import pytest
from scraper.base import normalize_name


def test_turkish_diacritics_lowercase():
    """Turkish lowercase diacritics: ğ->g, ş->s, ı->i, ö->o, ü->u, ç->c."""
    assert normalize_name("ğ") == "g"
    assert normalize_name("ş") == "s"
    assert normalize_name("ı") == "i"
    assert normalize_name("ö") == "o"
    assert normalize_name("ü") == "u"
    assert normalize_name("ç") == "c"


def test_turkish_diacritics_uppercase():
    """Turkish UPPERCASE diacritics: Ğ->g, Ş->s, İ->i, Ö->o, Ü->u, Ç->c."""
    assert normalize_name("Ğ") == "g"
    assert normalize_name("Ş") == "s"
    assert normalize_name("İ") == "i"
    assert normalize_name("Ö") == "o"
    assert normalize_name("Ü") == "u"
    assert normalize_name("Ç") == "c"


def test_whitespace_collapse():
    """Multiple spaces between words become a single space."""
    assert normalize_name("Göbek  Yeşil   Zeytin") == "gobek yesil zeytin"


def test_trim():
    """Leading and trailing whitespace is removed."""
    assert normalize_name("  Şeker  ") == "seker"


def test_uppercase_i_dot():
    """İrmik (uppercase dotted I) normalizes to irmik."""
    assert normalize_name("İrmik") == "irmik"


def test_uppercase_c_cedilla():
    """ÇOKOKREM normalizes to cokokrem."""
    assert normalize_name("ÇOKOKREM") == "cokokrem"


def test_mixed_real_product():
    """Göbek  Yeşil   Zeytin -> gobek yesil zeytin (mixed case + extra whitespace)."""
    result = normalize_name("Göbek  Yeşil   Zeytin")
    assert result == "gobek yesil zeytin"


def test_real_product_sut():
    """Süt 1L -> sut 1l."""
    assert normalize_name("Süt 1L") == "sut 1l"


def test_real_product_aycicek():
    """AYÇIÇEK YAĞI -> aycicek yagi."""
    assert normalize_name("AYÇIÇEK YAĞI") == "aycicek yagi"


def test_real_product_aycicek_with_unit():
    """AYÇIÇEK YAĞI 1L -> aycicek yagi 1l."""
    assert normalize_name("AYÇIÇEK YAĞI 1L") == "aycicek yagi 1l"
