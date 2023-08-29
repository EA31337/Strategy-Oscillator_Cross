/**
 * @file
 * Implements Oscillator Cross strategy based on the Oscillator Cross indicator.
 */

// Enums.

enum ENUM_STG_OSCILLATOR_CROSS_TYPE {
  STG_OSCILLATOR_CROSS_TYPE_0_NONE = 0,  // (None)
  STG_OSCILLATOR_CROSS_TYPE_ADX,         // ADX
  STG_OSCILLATOR_CROSS_TYPE_ADXW,        // ADXW
  STG_OSCILLATOR_CROSS_TYPE_GATOR,       // Gator
  STG_OSCILLATOR_CROSS_TYPE_MACD,        // MACD
  STG_OSCILLATOR_CROSS_TYPE_RVI,         // RVI: Relative Vigor Index
};

// User input params.
INPUT_GROUP("Oscillator Cross strategy: main strategy params");
INPUT ENUM_STG_OSCILLATOR_CROSS_TYPE Oscillator_Cross_Type = STG_OSCILLATOR_CROSS_TYPE_RVI;  // Oscillator type
INPUT_GROUP("Oscillator Cross strategy: strategy params");
INPUT float Oscillator_Cross_LotSize = 0;                // Lot size
INPUT int Oscillator_Cross_SignalOpenMethod = 2;         // Signal open method
INPUT float Oscillator_Cross_SignalOpenLevel = 10.0f;    // Signal open level
INPUT int Oscillator_Cross_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT int Oscillator_Cross_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT int Oscillator_Cross_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT int Oscillator_Cross_SignalCloseMethod = 0;        // Signal close method
INPUT int Oscillator_Cross_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT float Oscillator_Cross_SignalCloseLevel = 10.0f;   // Signal close level
INPUT int Oscillator_Cross_PriceStopMethod = 0;          // Price limit method
INPUT float Oscillator_Cross_PriceStopLevel = 2;         // Price limit level
INPUT int Oscillator_Cross_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT float Oscillator_Cross_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT short Oscillator_Cross_Shift = 0;                  // Shift
INPUT float Oscillator_Cross_OrderCloseLoss = 80;        // Order close loss
INPUT float Oscillator_Cross_OrderCloseProfit = 80;      // Order close profit
INPUT int Oscillator_Cross_OrderCloseTime = -30;         // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("Oscillator Cross strategy: ADX indicator params");
INPUT int Oscillator_Cross_Indi_ADX_Period = 16;                                    // Averaging period
INPUT ENUM_APPLIED_PRICE Oscillator_Cross_Indi_ADX_AppliedPrice = PRICE_TYPICAL;    // Applied price
INPUT int Oscillator_Cross_Indi_ADX_Shift = 0;                                      // Shift
INPUT ENUM_IDATA_SOURCE_TYPE Oscillator_Cross_Indi_ADX_SourceType = IDATA_BUILTIN;  // Source type
INPUT_GROUP("Oscillator Cross strategy: ADXW indicator params");
INPUT int Oscillator_Cross_Indi_ADXW_Period = 16;                                    // Averaging period
INPUT ENUM_APPLIED_PRICE Oscillator_Cross_Indi_ADXW_AppliedPrice = PRICE_TYPICAL;    // Applied price
INPUT int Oscillator_Cross_Indi_ADXW_Shift = 0;                                      // Shift
INPUT ENUM_IDATA_SOURCE_TYPE Oscillator_Cross_Indi_ADXW_SourceType = IDATA_BUILTIN;  // Source type
INPUT_GROUP("Oscillator strategy: Gator indicator params");
INPUT int Oscillator_Indi_Gator_Period_Jaw = 30;                            // Jaw Period
INPUT int Oscillator_Indi_Gator_Period_Teeth = 14;                          // Teeth Period
INPUT int Oscillator_Indi_Gator_Period_Lips = 6;                            // Lips Period
INPUT int Oscillator_Indi_Gator_Shift_Jaw = 2;                              // Jaw Shift
INPUT int Oscillator_Indi_Gator_Shift_Teeth = 2;                            // Teeth Shift
INPUT int Oscillator_Indi_Gator_Shift_Lips = 4;                             // Lips Shift
INPUT ENUM_MA_METHOD Oscillator_Indi_Gator_MA_Method = (ENUM_MA_METHOD)1;   // MA Method
INPUT ENUM_APPLIED_PRICE Oscillator_Indi_Gator_Applied_Price = PRICE_OPEN;  // Applied Price
INPUT int Oscillator_Indi_Gator_Shift = 0;                                  // Shift
INPUT_GROUP("Oscillator strategy: MACD indicator params");
INPUT int Oscillator_Indi_MACD_Period_Fast = 6;                            // Period Fast
INPUT int Oscillator_Indi_MACD_Period_Slow = 34;                           // Period Slow
INPUT int Oscillator_Indi_MACD_Period_Signal = 10;                         // Period Signal
INPUT ENUM_APPLIED_PRICE Oscillator_Indi_MACD_Applied_Price = PRICE_OPEN;  // Applied Price
INPUT int Oscillator_Indi_MACD_Shift = 0;                                  // Shift
INPUT_GROUP("Oscillator strategy: RVI indicator params");
INPUT unsigned int Oscillator_Indi_RVI_Period = 12;                                 // Averaging period
INPUT int Oscillator_Indi_RVI_Shift = 0;                                            // Shift
INPUT ENUM_IDATA_SOURCE_TYPE Oscillator_Cross_Indi_RVI_SourceType = IDATA_BUILTIN;  // Source type

// Structs.

// Defines struct with default user strategy values.
struct Stg_Oscillator_Cross_Params_Defaults : StgParams {
  Stg_Oscillator_Cross_Params_Defaults()
      : StgParams(::Oscillator_Cross_SignalOpenMethod, ::Oscillator_Cross_SignalOpenFilterMethod,
                  ::Oscillator_Cross_SignalOpenLevel, ::Oscillator_Cross_SignalOpenBoostMethod,
                  ::Oscillator_Cross_SignalCloseMethod, ::Oscillator_Cross_SignalCloseFilter,
                  ::Oscillator_Cross_SignalCloseLevel, ::Oscillator_Cross_PriceStopMethod,
                  ::Oscillator_Cross_PriceStopLevel, ::Oscillator_Cross_TickFilterMethod, ::Oscillator_Cross_MaxSpread,
                  ::Oscillator_Cross_Shift) {
    Set(STRAT_PARAM_LS, Oscillator_Cross_LotSize);
    Set(STRAT_PARAM_OCL, Oscillator_Cross_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, Oscillator_Cross_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, Oscillator_Cross_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, Oscillator_Cross_SignalOpenFilterTime);
  }
};

class Stg_Oscillator_Cross : public Strategy {
 public:
  Stg_Oscillator_Cross(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Oscillator_Cross *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Oscillator_Cross_Params_Defaults stg_oscillator_cross_defaults;
    StgParams _stg_params(stg_oscillator_cross_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Oscillator_Cross(_stg_params, _tparams, _cparams, "Oscillator_Cross");
    return _strat;
  }

  /**
   * Get's oscillator's max modes.
   */
  uint GetMaxModes(IndicatorBase *_indi) {
    uint _result = 0;
    switch (Oscillator_Cross_Type) {
      case STG_OSCILLATOR_CROSS_TYPE_ADX:
        _result = dynamic_cast<Indi_ADX *>(_indi).GetParams().GetMaxModes();
        break;
      case STG_OSCILLATOR_CROSS_TYPE_ADXW:
        _result = dynamic_cast<Indi_ADXW *>(_indi).GetParams().GetMaxModes();
        break;
      case STG_OSCILLATOR_CROSS_TYPE_GATOR:
        _result = dynamic_cast<Indi_Gator *>(_indi).GetParams().GetMaxModes();
        break;
      case STG_OSCILLATOR_CROSS_TYPE_MACD:
        _result = dynamic_cast<Indi_MACD *>(_indi).GetParams().GetMaxModes();
        break;
      case STG_OSCILLATOR_CROSS_TYPE_RVI:
        _result = dynamic_cast<Indi_RVI *>(_indi).GetParams().GetMaxModes();
        break;
      default:
        break;
    }
    return _result;
  }

  /**
   * Validate oscillator's entry.
   */
  bool IsValidEntry(IndicatorBase *_indi, int _shift = 0) {
    bool _result = true;
    switch (Oscillator_Cross_Type) {
      case STG_OSCILLATOR_CROSS_TYPE_ADX:
        _result &= dynamic_cast<Indi_ADX *>(_indi).GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift) &&
                   dynamic_cast<Indi_ADX *>(_indi).GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift + 1);
        break;
      case STG_OSCILLATOR_CROSS_TYPE_ADXW:
        _result &= dynamic_cast<Indi_ADXW *>(_indi).GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift) &&
                   dynamic_cast<Indi_ADXW *>(_indi).GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift + 1);
        break;
      case STG_OSCILLATOR_CROSS_TYPE_GATOR:
        _result &= dynamic_cast<Indi_Gator *>(_indi).GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift) &&
                   dynamic_cast<Indi_Gator *>(_indi).GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift + 1);
        break;
      case STG_OSCILLATOR_CROSS_TYPE_MACD:
        _result &= dynamic_cast<Indi_MACD *>(_indi).GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift) &&
                   dynamic_cast<Indi_MACD *>(_indi).GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift + 1);
        break;
      case STG_OSCILLATOR_CROSS_TYPE_RVI:
        _result &= dynamic_cast<Indi_RVI *>(_indi).GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift) &&
                   dynamic_cast<Indi_RVI *>(_indi).GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift + 1);
        break;
      default:
        break;
    }
    return _result;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    // Initialize indicators.
    switch (Oscillator_Cross_Type) {
      case STG_OSCILLATOR_CROSS_TYPE_ADX:  // ADX
      {
        IndiADXParams _adx_params(::Oscillator_Cross_Indi_ADX_Period, ::Oscillator_Cross_Indi_ADX_AppliedPrice,
                                  ::Oscillator_Cross_Indi_ADX_Shift);
        _adx_params.SetDataSourceType(::Oscillator_Cross_Indi_ADX_SourceType);
        _adx_params.SetTf(Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF));
        SetIndicator(new Indi_ADX(_adx_params), ::Oscillator_Cross_Type);
        break;
      }
      case STG_OSCILLATOR_CROSS_TYPE_ADXW:  // ADXW
      {
        IndiADXWParams _adxw_params(::Oscillator_Cross_Indi_ADXW_Period, ::Oscillator_Cross_Indi_ADXW_AppliedPrice,
                                    ::Oscillator_Cross_Indi_ADXW_Shift);
        _adxw_params.SetDataSourceType(::Oscillator_Cross_Indi_ADXW_SourceType);
        _adxw_params.SetTf(Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF));
        SetIndicator(new Indi_ADXW(_adxw_params), ::Oscillator_Cross_Type);
        break;
      }
      case STG_OSCILLATOR_CROSS_TYPE_GATOR:  // Gator
      {
        IndiGatorParams _indi_params(::Oscillator_Indi_Gator_Period_Jaw, ::Oscillator_Indi_Gator_Shift_Jaw,
                                     ::Oscillator_Indi_Gator_Period_Teeth, ::Oscillator_Indi_Gator_Shift_Teeth,
                                     ::Oscillator_Indi_Gator_Period_Lips, ::Oscillator_Indi_Gator_Shift_Lips,
                                     ::Oscillator_Indi_Gator_MA_Method, ::Oscillator_Indi_Gator_Applied_Price,
                                     ::Oscillator_Indi_Gator_Shift);
        _indi_params.SetTf(Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF));
        SetIndicator(new Indi_Gator(_indi_params), ::Oscillator_Cross_Type);
        break;
      }
      case STG_OSCILLATOR_CROSS_TYPE_MACD:  // MACD
      {
        IndiMACDParams _indi_params(::Oscillator_Indi_MACD_Period_Fast, ::Oscillator_Indi_MACD_Period_Slow,
                                    ::Oscillator_Indi_MACD_Period_Signal, ::Oscillator_Indi_MACD_Applied_Price,
                                    ::Oscillator_Indi_MACD_Shift);
        _indi_params.SetTf(Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF));
        SetIndicator(new Indi_MACD(_indi_params), ::Oscillator_Cross_Type);
        break;
      }
      case STG_OSCILLATOR_CROSS_TYPE_RVI:  // RVI
      {
        IndiRVIParams _indi_params(::Oscillator_Indi_RVI_Period, ::Oscillator_Indi_RVI_Shift);
        _indi_params.SetDataSourceType(::Oscillator_Cross_Indi_RVI_SourceType);
        _indi_params.SetTf(Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF));
        SetIndicator(new Indi_RVI(_indi_params), ::Oscillator_Cross_Type);
        break;
      }
      case STG_OSCILLATOR_CROSS_TYPE_0_NONE:  // (None)
      default:
        break;
    }
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    IndicatorBase *_indi = GetIndicator(::Oscillator_Cross_Type);
    // uint _ishift = _indi.GetShift();
    bool _result = Oscillator_Cross_Type != STG_OSCILLATOR_CROSS_TYPE_0_NONE && IsValidEntry(_indi, _shift);
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    float _value_avg[4] = {0.0f, 0.0f, 0.0f, 0.0f};
    uint _max_modes = GetMaxModes(_indi);
    for (int _vshift = 0; _vshift < ArraySize(_value_avg); _vshift++) {
      for (uint _imode = 0; _imode < _max_modes; _imode++) {
        _value_avg[_vshift] += (float)_indi[_shift + _vshift][(int)_imode];
      }
      _value_avg[_vshift] /= (float)_max_modes;
    }
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        // Buy signal.
        _result &= _value_avg[0] > _value_avg[1];
        _result &= _value_avg[1] < _value_avg[2];
        _result &= Math::ChangeInPct(_value_avg[1], _value_avg[0], true) > _level;
        if (_result && _method != 0) {
          if (METHOD(_method, 0)) _result &= _value_avg[1] < _value_avg[3];
          if (METHOD(_method, 1))
            _result &= fmax4(_value_avg[0], _value_avg[1], _value_avg[2], _value_avg[3]) == _value_avg[0];
        }
        break;
      case ORDER_TYPE_SELL:
        // Sell signal.
        _result &= _value_avg[0] < _value_avg[1];
        _result &= _value_avg[1] > _value_avg[2];
        _result &= Math::ChangeInPct(_value_avg[1], _value_avg[0], true) < _level;
        if (_result && _method != 0) {
          if (METHOD(_method, 0)) _result &= _value_avg[1] > _value_avg[3];
          if (METHOD(_method, 1))
            _result &= fmin4(_value_avg[0], _value_avg[1], _value_avg[2], _value_avg[3]) == _value_avg[0];
        }
        break;
    }
    return _result;
  }
};