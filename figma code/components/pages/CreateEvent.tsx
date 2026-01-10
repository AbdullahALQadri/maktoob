import { Check, Sparkles, Zap, Crown, ArrowRight, ArrowLeft, Plus, Edit3, Star, Users, Upload, Mail, MessageSquare, FileSpreadsheet, UserPlus, X } from 'lucide-react';
import { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';

interface CreateEventProps {
  onComplete: (eventId: string) => void;
}

export function CreateEvent({ onComplete }: CreateEventProps) {
  const [currentStep, setCurrentStep] = useState(1);
  const [selectedPackage, setSelectedPackage] = useState<string | null>(null);
  const [selectedVenue, setSelectedVenue] = useState<string | null>(null);
  const [showCustomVenue, setShowCustomVenue] = useState(false);
  const [customVenue, setCustomVenue] = useState({ name: '', address: '', capacity: '' });
  const [selectedEventType, setSelectedEventType] = useState<string | null>(null);
  const [showCustomEventType, setShowCustomEventType] = useState(false);
  const [customEventType, setCustomEventType] = useState('');
  const [selectedTemplate, setSelectedTemplate] = useState<string | null>(null);
  const [requestCustomTemplate, setRequestCustomTemplate] = useState(false);
  const [eventDetails, setEventDetails] = useState({
    name: '',
    date: '',
    time: '',
    responseDeadline: '',
    maxCompanions: '2',
    allowCompanions: true,
  });
  const [guestMethod, setGuestMethod] = useState<string | null>(null);
  const [manualGuests, setManualGuests] = useState<{ name: string; email: string; phone: string }[]>([]);
  const [currentGuest, setCurrentGuest] = useState({ name: '', email: '', phone: '' });
  const [excelFile, setExcelFile] = useState<File | null>(null);

  const totalSteps = 7;

  const packages = [
    {
      id: 'silver',
      name: 'Silver',
      price: '299',
      invitations: 100,
      features: ['Basic Templates', 'WhatsApp Delivery', 'QR Code Check-in', 'Email Support'],
      gradient: 'from-gray-400 to-gray-500',
      icon: Sparkles,
    },
    {
      id: 'gold',
      name: 'Gold',
      price: '599',
      invitations: 300,
      features: ['Premium Templates', 'WhatsApp + SMS', 'QR Code Check-in', 'Analytics Dashboard', 'Priority Support'],
      gradient: 'from-yellow-400 to-amber-500',
      icon: Zap,
      recommended: true,
    },
    {
      id: 'platinum',
      name: 'Platinum',
      price: '999',
      invitations: Infinity,
      features: ['Custom Templates', 'All Channels', 'Advanced Analytics', 'Custom Branding', '24/7 Support', 'API Access'],
      gradient: 'from-purple-500 to-pink-500',
      icon: Crown,
    },
  ];

  const venues = [
    { id: '1', name: 'Grand Hotel Ballroom', capacity: 300, icon: '🏨' },
    { id: '2', name: 'Convention Center', capacity: 500, icon: '🏢' },
    { id: '3', name: 'Beach Resort', capacity: 150, icon: '🏖️' },
    { id: '4', name: 'University Hall', capacity: 400, icon: '🎓' },
  ];

  const eventTypes = [
    { id: 'wedding', name: 'Wedding', icon: '💒', color: 'from-pink-500 to-rose-500' },
    { id: 'corporate', name: 'Corporate', icon: '🏢', color: 'from-blue-500 to-cyan-500' },
    { id: 'birthday', name: 'Birthday', icon: '🎂', color: 'from-amber-500 to-orange-500' },
    { id: 'graduation', name: 'Graduation', icon: '🎓', color: 'from-green-500 to-emerald-500' },
    { id: 'conference', name: 'Conference', icon: '🎤', color: 'from-purple-500 to-indigo-500' },
    { id: 'charity', name: 'Charity', icon: '❤️', color: 'from-red-500 to-pink-500' },
  ];

  const templates = [
    { id: 'elegant', name: 'Elegant Gold', preview: '✨', color: 'from-yellow-600 to-amber-600' },
    { id: 'modern', name: 'Modern Minimal', preview: '▫️', color: 'from-gray-700 to-gray-900' },
    { id: 'floral', name: 'Floral Dream', preview: '🌸', color: 'from-pink-500 to-rose-500' },
    { id: 'classic', name: 'Classic White', preview: '⬜', color: 'from-gray-100 to-gray-300' },
    { id: 'luxury', name: 'Luxury Black', preview: '⬛', color: 'from-black to-gray-800' },
    { id: 'colorful', name: 'Colorful Joy', preview: '🎨', color: 'from-purple-500 to-pink-500' },
  ];

  const getPackageLimit = () => {
    const pkg = packages.find(p => p.id === selectedPackage);
    return pkg?.invitations || 0;
  };

  const canProceedStep1 = selectedPackage;
  const canProceedStep2 = selectedVenue || (showCustomVenue && customVenue.name && customVenue.address);
  const canProceedStep3 = selectedEventType || (showCustomEventType && customEventType);
  const canProceedStep4 = selectedTemplate || requestCustomTemplate;
  const canProceedStep5 = eventDetails.name && eventDetails.date && eventDetails.time;
  const canProceedStep6 = guestMethod;

  const handleNext = () => {
    if (currentStep < totalSteps) {
      setCurrentStep(currentStep + 1);
    }
  };

  const handleBack = () => {
    if (currentStep > 1) {
      setCurrentStep(currentStep - 1);
    }
  };

  const handleSaveDraft = () => {
    alert('Event saved as draft!');
  };

  const handleSubmit = () => {
    onComplete('event-123');
  };

  const handleAddGuest = () => {
    const packageLimit = getPackageLimit();
    const currentGuestCount = manualGuests.length;
    
    if (packageLimit !== Infinity && currentGuestCount >= packageLimit) {
      alert(`You have reached your package limit of ${packageLimit} guests!`);
      return;
    }
    
    if (currentGuest.name && currentGuest.email && currentGuest.phone) {
      setManualGuests([...manualGuests, currentGuest]);
      setCurrentGuest({ name: '', email: '', phone: '' });
    }
  };

  const handleRemoveGuest = (index: number) => {
    setManualGuests(manualGuests.filter((_, i) => i !== index));
  };

  const renderStepContent = () => {
    switch (currentStep) {
      case 1:
        return (
          <motion.div
            key="step1"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            className="space-y-4"
          >
            <h2 className="text-xl font-bold text-gray-900 mb-4">Choose Your Package</h2>
            {packages.map((pkg, index) => {
              const Icon = pkg.icon;
              const invitationsDisplay = pkg.invitations === Infinity ? 'Unlimited' : pkg.invitations;
              return (
                <motion.div
                  key={pkg.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.1 }}
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={() => setSelectedPackage(pkg.id)}
                  className={`relative rounded-3xl p-6 cursor-pointer transition-all ${
                    selectedPackage === pkg.id
                      ? 'bg-gradient-to-br ' + pkg.gradient + ' text-white shadow-2xl'
                      : 'bg-white shadow-lg'
                  }`}
                >
                  {pkg.recommended && (
                    <div className="absolute -top-3 right-6 bg-gradient-to-r from-purple-600 to-pink-600 text-white text-xs px-4 py-1.5 rounded-full font-bold shadow-lg">
                      ⭐ Recommended
                    </div>
                  )}
                  
                  <div className="flex items-start justify-between mb-4">
                    <div className="flex items-center gap-3">
                      <div className={`w-12 h-12 rounded-2xl flex items-center justify-center ${
                        selectedPackage === pkg.id ? 'bg-white/20' : 'bg-gradient-to-br ' + pkg.gradient
                      }`}>
                        <Icon className="w-6 h-6 text-white" />
                      </div>
                      <div>
                        <h3 className={`font-bold text-xl ${selectedPackage === pkg.id ? 'text-white' : 'text-gray-900'}`}>
                          {pkg.name}
                        </h3>
                        <p className={`text-xs mt-0.5 ${selectedPackage === pkg.id ? 'text-white/80' : 'text-gray-600'}`}>
                          Up to {invitationsDisplay} invitations
                        </p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className={`text-3xl font-bold ${selectedPackage === pkg.id ? 'text-white' : 'text-gray-900'}`}>
                        ${pkg.price}
                      </p>
                    </div>
                  </div>

                  <div className="space-y-2.5">
                    {pkg.features.map((feature, idx) => (
                      <div key={idx} className="flex items-center gap-2.5">
                        <div className={`w-5 h-5 rounded-full flex items-center justify-center ${
                          selectedPackage === pkg.id ? 'bg-white/20' : 'bg-green-100'
                        }`}>
                          <Check className={`w-3 h-3 ${selectedPackage === pkg.id ? 'text-white' : 'text-green-600'}`} />
                        </div>
                        <span className={`text-sm font-medium ${selectedPackage === pkg.id ? 'text-white' : 'text-gray-700'}`}>
                          {feature}
                        </span>
                      </div>
                    ))}
                  </div>
                </motion.div>
              );
            })}
          </motion.div>
        );

      case 2:
        return (
          <motion.div
            key="step2"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            className="space-y-4"
          >
            <h2 className="text-xl font-bold text-gray-900 mb-4">Select Venue</h2>
            
            <div className="grid grid-cols-2 gap-3">
              {venues.map((venue) => (
                <motion.div
                  key={venue.id}
                  whileTap={{ scale: 0.95 }}
                  onClick={() => {
                    setSelectedVenue(venue.id);
                    setShowCustomVenue(false);
                  }}
                  className={`p-4 rounded-2xl cursor-pointer transition-all ${
                    selectedVenue === venue.id
                      ? 'bg-gradient-to-br from-purple-600 to-pink-600 text-white shadow-xl'
                      : 'bg-white shadow-md'
                  }`}
                >
                  <div className="text-3xl mb-2">{venue.icon}</div>
                  <h3 className={`font-bold text-sm mb-1 ${selectedVenue === venue.id ? 'text-white' : 'text-gray-900'}`}>
                    {venue.name}
                  </h3>
                  <p className={`text-xs ${selectedVenue === venue.id ? 'text-white/80' : 'text-gray-600'}`}>
                    Capacity: {venue.capacity}
                  </p>
                </motion.div>
              ))}
            </div>

            <motion.button
              whileTap={{ scale: 0.95 }}
              onClick={() => {
                setShowCustomVenue(!showCustomVenue);
                setSelectedVenue(null);
              }}
              className={`w-full p-4 rounded-2xl border-2 border-dashed transition-all ${
                showCustomVenue
                  ? 'border-purple-600 bg-purple-50'
                  : 'border-gray-300 bg-white'
              }`}
            >
              <Plus className="w-6 h-6 mx-auto mb-1 text-purple-600" />
              <p className="font-bold text-sm text-gray-900">Add Custom Venue</p>
            </motion.button>

            {showCustomVenue && (
              <motion.div
                initial={{ height: 0, opacity: 0 }}
                animate={{ height: 'auto', opacity: 1 }}
                className="bg-white rounded-2xl p-4 shadow-lg space-y-3"
              >
                <input
                  type="text"
                  placeholder="Venue Name"
                  value={customVenue.name}
                  onChange={(e) => setCustomVenue({ ...customVenue, name: e.target.value })}
                  className="w-full px-4 py-3 bg-gray-50 border-2 border-gray-100 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-purple-600"
                />
                <input
                  type="text"
                  placeholder="Address"
                  value={customVenue.address}
                  onChange={(e) => setCustomVenue({ ...customVenue, address: e.target.value })}
                  className="w-full px-4 py-3 bg-gray-50 border-2 border-gray-100 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-purple-600"
                />
                <input
                  type="number"
                  placeholder="Capacity"
                  value={customVenue.capacity}
                  onChange={(e) => setCustomVenue({ ...customVenue, capacity: e.target.value })}
                  className="w-full px-4 py-3 bg-gray-50 border-2 border-gray-100 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-purple-600"
                />
              </motion.div>
            )}
          </motion.div>
        );

      case 3:
        return (
          <motion.div
            key="step3"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            className="space-y-4"
          >
            <h2 className="text-xl font-bold text-gray-900 mb-4">Event Type</h2>
            
            <div className="grid grid-cols-3 gap-3">
              {eventTypes.map((type) => (
                <motion.button
                  key={type.id}
                  whileTap={{ scale: 0.95 }}
                  onClick={() => {
                    setSelectedEventType(type.id);
                    setShowCustomEventType(false);
                  }}
                  className={`relative p-4 rounded-2xl transition-all ${
                    selectedEventType === type.id
                      ? `bg-gradient-to-br ${type.color} text-white shadow-xl`
                      : 'bg-white shadow-md'
                  }`}
                >
                  <div className="text-3xl mb-2">{type.icon}</div>
                  <div className={`text-xs font-bold ${selectedEventType === type.id ? 'text-white' : 'text-gray-900'}`}>
                    {type.name}
                  </div>
                  {selectedEventType === type.id && (
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      className="absolute -top-2 -right-2 w-6 h-6 bg-white rounded-full flex items-center justify-center shadow-lg"
                    >
                      <Check className="w-4 h-4 text-purple-600" />
                    </motion.div>
                  )}
                </motion.button>
              ))}
            </div>

            <motion.button
              whileTap={{ scale: 0.95 }}
              onClick={() => {
                setShowCustomEventType(!showCustomEventType);
                setSelectedEventType(null);
              }}
              className={`w-full p-4 rounded-2xl border-2 border-dashed transition-all ${
                showCustomEventType
                  ? 'border-purple-600 bg-purple-50'
                  : 'border-gray-300 bg-white'
              }`}
            >
              <Plus className="w-6 h-6 mx-auto mb-1 text-purple-600" />
              <p className="font-bold text-sm text-gray-900">Add Custom Type</p>
            </motion.button>

            {showCustomEventType && (
              <motion.div
                initial={{ height: 0, opacity: 0 }}
                animate={{ height: 'auto', opacity: 1 }}
                className="bg-white rounded-2xl p-4 shadow-lg"
              >
                <input
                  type="text"
                  placeholder="Custom Event Type"
                  value={customEventType}
                  onChange={(e) => setCustomEventType(e.target.value)}
                  className="w-full px-4 py-3 bg-gray-50 border-2 border-gray-100 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-purple-600"
                />
              </motion.div>
            )}
          </motion.div>
        );

      case 4:
        return (
          <motion.div
            key="step4"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            className="space-y-4"
          >
            <h2 className="text-xl font-bold text-gray-900 mb-4">Choose Template</h2>
            
            <div className="grid grid-cols-2 gap-3">
              {templates.map((template) => (
                <motion.div
                  key={template.id}
                  whileTap={{ scale: 0.95 }}
                  onClick={() => {
                    setSelectedTemplate(template.id);
                    setRequestCustomTemplate(false);
                  }}
                  className={`relative p-4 rounded-2xl cursor-pointer transition-all ${
                    selectedTemplate === template.id
                      ? `bg-gradient-to-br ${template.color} text-white shadow-xl`
                      : 'bg-white shadow-md'
                  }`}
                >
                  <div className="text-4xl mb-3">{template.preview}</div>
                  <h3 className={`font-bold text-sm ${selectedTemplate === template.id ? 'text-white' : 'text-gray-900'}`}>
                    {template.name}
                  </h3>
                  {selectedTemplate === template.id && (
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      className="absolute -top-2 -right-2 w-6 h-6 bg-white rounded-full flex items-center justify-center shadow-lg"
                    >
                      <Check className="w-4 h-4 text-purple-600" />
                    </motion.div>
                  )}
                </motion.div>
              ))}
            </div>

            <motion.button
              whileTap={{ scale: 0.95 }}
              onClick={() => {
                setRequestCustomTemplate(!requestCustomTemplate);
                setSelectedTemplate(null);
              }}
              className={`w-full p-5 rounded-2xl transition-all ${
                requestCustomTemplate
                  ? 'bg-gradient-to-br from-purple-600 to-pink-600 text-white shadow-xl'
                  : 'bg-white border-2 border-purple-300 shadow-md'
              }`}
            >
              <Star className={`w-7 h-7 mx-auto mb-2 ${requestCustomTemplate ? 'text-white' : 'text-purple-600'}`} />
              <p className={`font-bold ${requestCustomTemplate ? 'text-white' : 'text-gray-900'}`}>
                Request Custom Template
              </p>
              <p className={`text-xs mt-1 ${requestCustomTemplate ? 'text-white/80' : 'text-gray-600'}`}>
                Our team will create a unique design for you
              </p>
            </motion.button>
          </motion.div>
        );

      case 5:
        return (
          <motion.div
            key="step5"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            className="space-y-4"
          >
            <h2 className="text-xl font-bold text-gray-900 mb-4">Event Details</h2>
            
            <div className="bg-white rounded-2xl p-5 shadow-lg space-y-4">
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">Event Name</label>
                <input
                  type="text"
                  placeholder="Enter event name"
                  value={eventDetails.name}
                  onChange={(e) => setEventDetails({ ...eventDetails, name: e.target.value })}
                  className="w-full px-4 py-3 bg-gray-50 border-2 border-gray-100 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-purple-600"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">Date</label>
                  <input
                    type="date"
                    value={eventDetails.date}
                    onChange={(e) => setEventDetails({ ...eventDetails, date: e.target.value })}
                    className="w-full px-4 py-3 bg-gray-50 border-2 border-gray-100 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-purple-600"
                  />
                </div>
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">Time</label>
                  <input
                    type="time"
                    value={eventDetails.time}
                    onChange={(e) => setEventDetails({ ...eventDetails, time: e.target.value })}
                    className="w-full px-4 py-3 bg-gray-50 border-2 border-gray-100 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-purple-600"
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">Response Deadline</label>
                <input
                  type="date"
                  value={eventDetails.responseDeadline}
                  onChange={(e) => setEventDetails({ ...eventDetails, responseDeadline: e.target.value })}
                  className="w-full px-4 py-3 bg-gray-50 border-2 border-gray-100 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-purple-600"
                />
              </div>

              <div className="bg-purple-50 rounded-xl p-4">
                <div className="flex items-center justify-between">
                  <div>
                    <label className="text-sm font-semibold text-gray-900">Allow Companions</label>
                    <p className="text-xs text-gray-600 mt-0.5">Guests can bring +1</p>
                  </div>
                  <motion.button
                    whileTap={{ scale: 0.95 }}
                    onClick={() => setEventDetails({ ...eventDetails, allowCompanions: !eventDetails.allowCompanions })}
                    className={`w-14 h-8 rounded-full transition-all ${
                      eventDetails.allowCompanions ? 'bg-purple-600' : 'bg-gray-300'
                    }`}
                  >
                    <motion.div 
                      layout
                      className={`w-6 h-6 bg-white rounded-full shadow-md ${
                        eventDetails.allowCompanions ? 'translate-x-7' : 'translate-x-1'
                      }`}
                    />
                  </motion.button>
                </div>
                <AnimatePresence>
                  {eventDetails.allowCompanions && (
                    <motion.div
                      initial={{ height: 0, opacity: 0 }}
                      animate={{ height: 'auto', opacity: 1 }}
                      exit={{ height: 0, opacity: 0 }}
                      className="mt-3"
                    >
                      <input
                        type="number"
                        placeholder="Max companions"
                        value={eventDetails.maxCompanions}
                        onChange={(e) => setEventDetails({ ...eventDetails, maxCompanions: e.target.value })}
                        className="w-full px-4 py-3 bg-white border-2 border-purple-100 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-purple-600"
                      />
                    </motion.div>
                  )}
                </AnimatePresence>
              </div>
            </div>
          </motion.div>
        );

      case 6:
        const packageLimit = getPackageLimit();
        const currentGuestCount = manualGuests.length;
        const remainingSlots = packageLimit === Infinity ? Infinity : packageLimit - currentGuestCount;

        return (
          <motion.div
            key="step6"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            className="space-y-4"
          >
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-xl font-bold text-gray-900">Add Guests</h2>
              <div className="text-right">
                <p className="text-xs text-gray-500">Package Limit</p>
                <p className="text-sm font-bold text-purple-600">
                  {currentGuestCount} / {packageLimit === Infinity ? '∞' : packageLimit}
                </p>
              </div>
            </div>

            {/* Package Limit Progress */}
            {packageLimit !== Infinity && (
              <div className="bg-white rounded-2xl p-4 shadow-lg">
                <div className="flex justify-between text-xs mb-2">
                  <span className="text-gray-600 font-medium">Guest Capacity</span>
                  <span className="font-bold text-gray-900">{remainingSlots} slots remaining</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2 overflow-hidden">
                  <motion.div 
                    initial={{ width: 0 }}
                    animate={{ width: `${(currentGuestCount / packageLimit) * 100}%` }}
                    transition={{ duration: 0.5 }}
                    className={`h-2 rounded-full ${
                      currentGuestCount >= packageLimit 
                        ? 'bg-gradient-to-r from-red-500 to-orange-500' 
                        : 'bg-gradient-to-r from-purple-600 to-pink-600'
                    }`}
                  />
                </div>
              </div>
            )}
            
            {/* Guest Method Selection */}
            <h3 className="text-sm font-semibold text-gray-700 mt-6 mb-3">How would you like to add guests?</h3>
            
            <div className="space-y-3">
              {/* Invite via Messaging */}
              <motion.div
                whileTap={{ scale: 0.98 }}
                onClick={() => setGuestMethod('invite')}
                className={`relative rounded-2xl p-5 cursor-pointer transition-all ${
                  guestMethod === 'invite'
                    ? 'bg-gradient-to-br from-blue-600 to-cyan-600 text-white shadow-xl'
                    : 'bg-white shadow-lg'
                }`}
              >
                <div className="flex items-center gap-4">
                  <div className={`w-12 h-12 rounded-xl flex items-center justify-center ${
                    guestMethod === 'invite' ? 'bg-white/20' : 'bg-blue-50'
                  }`}>
                    <MessageSquare className={`w-6 h-6 ${guestMethod === 'invite' ? 'text-white' : 'text-blue-600'}`} />
                  </div>
                  <div className="flex-1">
                    <h3 className={`font-bold text-base ${guestMethod === 'invite' ? 'text-white' : 'text-gray-900'}`}>
                      Reach Them Directly
                    </h3>
                    <p className={`text-xs mt-1 ${guestMethod === 'invite' ? 'text-white/80' : 'text-gray-600'}`}>
                      Send invites via WhatsApp, Email & SMS
                    </p>
                  </div>
                  {guestMethod === 'invite' && (
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      className="w-6 h-6 bg-white rounded-full flex items-center justify-center"
                    >
                      <Check className="w-4 h-4 text-blue-600" />
                    </motion.div>
                  )}
                </div>
              </motion.div>

              {/* Upload Excel */}
              <motion.div
                whileTap={{ scale: 0.98 }}
                onClick={() => setGuestMethod('excel')}
                className={`relative rounded-2xl p-5 cursor-pointer transition-all ${
                  guestMethod === 'excel'
                    ? 'bg-gradient-to-br from-green-600 to-emerald-600 text-white shadow-xl'
                    : 'bg-white shadow-lg'
                }`}
              >
                <div className="flex items-center gap-4">
                  <div className={`w-12 h-12 rounded-xl flex items-center justify-center ${
                    guestMethod === 'excel' ? 'bg-white/20' : 'bg-green-50'
                  }`}>
                    <FileSpreadsheet className={`w-6 h-6 ${guestMethod === 'excel' ? 'text-white' : 'text-green-600'}`} />
                  </div>
                  <div className="flex-1">
                    <h3 className={`font-bold text-base ${guestMethod === 'excel' ? 'text-white' : 'text-gray-900'}`}>
                      Upload Excel File
                    </h3>
                    <p className={`text-xs mt-1 ${guestMethod === 'excel' ? 'text-white/80' : 'text-gray-600'}`}>
                      Import guest list from spreadsheet
                    </p>
                  </div>
                  {guestMethod === 'excel' && (
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      className="w-6 h-6 bg-white rounded-full flex items-center justify-center"
                    >
                      <Check className="w-4 h-4 text-green-600" />
                    </motion.div>
                  )}
                </div>
              </motion.div>

              {/* Add Manually */}
              <motion.div
                whileTap={{ scale: 0.98 }}
                onClick={() => setGuestMethod('manual')}
                className={`relative rounded-2xl p-5 cursor-pointer transition-all ${
                  guestMethod === 'manual'
                    ? 'bg-gradient-to-br from-purple-600 to-pink-600 text-white shadow-xl'
                    : 'bg-white shadow-lg'
                }`}
              >
                <div className="flex items-center gap-4">
                  <div className={`w-12 h-12 rounded-xl flex items-center justify-center ${
                    guestMethod === 'manual' ? 'bg-white/20' : 'bg-purple-50'
                  }`}>
                    <UserPlus className={`w-6 h-6 ${guestMethod === 'manual' ? 'text-white' : 'text-purple-600'}`} />
                  </div>
                  <div className="flex-1">
                    <h3 className={`font-bold text-base ${guestMethod === 'manual' ? 'text-white' : 'text-gray-900'}`}>
                      Add One by One
                    </h3>
                    <p className={`text-xs mt-1 ${guestMethod === 'manual' ? 'text-white/80' : 'text-gray-600'}`}>
                      Manually enter each guest's details
                    </p>
                  </div>
                  {guestMethod === 'manual' && (
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      className="w-6 h-6 bg-white rounded-full flex items-center justify-center"
                    >
                      <Check className="w-4 h-4 text-purple-600" />
                    </motion.div>
                  )}
                </div>
              </motion.div>
            </div>

            {/* Method-specific content */}
            <AnimatePresence mode="wait">
              {guestMethod === 'excel' && (
                <motion.div
                  initial={{ height: 0, opacity: 0 }}
                  animate={{ height: 'auto', opacity: 1 }}
                  exit={{ height: 0, opacity: 0 }}
                  className="bg-white rounded-2xl p-5 shadow-lg space-y-3"
                >
                  <div className="flex items-center gap-2 text-sm text-gray-700">
                    <Upload className="w-4 h-4" />
                    <span className="font-semibold">Upload Guest List</span>
                  </div>
                  <label className="block">
                    <div className="border-2 border-dashed border-gray-300 rounded-xl p-6 text-center cursor-pointer hover:border-purple-500 transition-colors">
                      <FileSpreadsheet className="w-10 h-10 mx-auto mb-2 text-gray-400" />
                      <p className="text-sm font-medium text-gray-700">
                        {excelFile ? excelFile.name : 'Click to upload Excel file'}
                      </p>
                      <p className="text-xs text-gray-500 mt-1">.xlsx or .xls format</p>
                    </div>
                    <input
                      type="file"
                      accept=".xlsx, .xls"
                      onChange={(e) => setExcelFile(e.target.files ? e.target.files[0] : null)}
                      className="hidden"
                    />
                  </label>
                  {excelFile && (
                    <p className="text-xs text-green-600 text-center">✓ File uploaded successfully</p>
                  )}
                </motion.div>
              )}

              {guestMethod === 'manual' && (
                <motion.div
                  initial={{ height: 0, opacity: 0 }}
                  animate={{ height: 'auto', opacity: 1 }}
                  exit={{ height: 0, opacity: 0 }}
                  className="bg-white rounded-2xl p-5 shadow-lg space-y-4"
                >
                  <div className="flex items-center gap-2 text-sm text-gray-700">
                    <UserPlus className="w-4 h-4" />
                    <span className="font-semibold">Add Guest Details</span>
                  </div>
                  
                  <div className="space-y-3">
                    <input
                      type="text"
                      placeholder="Full Name"
                      value={currentGuest.name}
                      onChange={(e) => setCurrentGuest({ ...currentGuest, name: e.target.value })}
                      className="w-full px-4 py-3 bg-gray-50 border-2 border-gray-100 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-purple-600"
                    />
                    <input
                      type="email"
                      placeholder="Email Address"
                      value={currentGuest.email}
                      onChange={(e) => setCurrentGuest({ ...currentGuest, email: e.target.value })}
                      className="w-full px-4 py-3 bg-gray-50 border-2 border-gray-100 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-purple-600"
                    />
                    <input
                      type="tel"
                      placeholder="Phone Number"
                      value={currentGuest.phone}
                      onChange={(e) => setCurrentGuest({ ...currentGuest, phone: e.target.value })}
                      className="w-full px-4 py-3 bg-gray-50 border-2 border-gray-100 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-purple-600"
                    />
                  </div>

                  <motion.button
                    whileTap={{ scale: 0.95 }}
                    onClick={handleAddGuest}
                    disabled={!currentGuest.name || !currentGuest.email || !currentGuest.phone}
                    className={`w-full py-3.5 rounded-2xl font-bold shadow-lg transition-all ${
                      currentGuest.name && currentGuest.email && currentGuest.phone
                        ? 'bg-gradient-to-r from-purple-600 to-pink-600 text-white'
                        : 'bg-gray-200 text-gray-400'
                    }`}
                  >
                    <Plus className="w-5 h-5 inline mr-2" />
                    Add Guest
                  </motion.button>

                  {/* Guest List */}
                  {manualGuests.length > 0 && (
                    <div className="mt-4 pt-4 border-t border-gray-100">
                      <p className="text-sm font-semibold text-gray-700 mb-3">
                        Added Guests ({manualGuests.length})
                      </p>
                      <div className="space-y-2 max-h-48 overflow-y-auto">
                        {manualGuests.map((guest, index) => (
                          <motion.div 
                            key={index} 
                            initial={{ opacity: 0, x: -20 }}
                            animate={{ opacity: 1, x: 0 }}
                            className="bg-gray-50 rounded-xl p-3 relative"
                          >
                            <button
                              onClick={() => handleRemoveGuest(index)}
                              className="absolute top-2 right-2 w-6 h-6 bg-red-100 rounded-full flex items-center justify-center hover:bg-red-200 transition-colors"
                            >
                              <X className="w-3 h-3 text-red-600" />
                            </button>
                            <p className="font-medium text-sm text-gray-900 pr-8">{guest.name}</p>
                            <p className="text-xs text-gray-600">{guest.email}</p>
                            <p className="text-xs text-gray-600">{guest.phone}</p>
                          </motion.div>
                        ))}
                      </div>
                    </div>
                  )}
                </motion.div>
              )}

              {guestMethod === 'invite' && (
                <motion.div
                  initial={{ height: 0, opacity: 0 }}
                  animate={{ height: 'auto', opacity: 1 }}
                  exit={{ height: 0, opacity: 0 }}
                  className="bg-gradient-to-br from-blue-50 to-cyan-50 rounded-2xl p-5 shadow-lg"
                >
                  <div className="text-center">
                    <MessageSquare className="w-12 h-12 mx-auto mb-3 text-blue-600" />
                    <h3 className="font-bold text-gray-900 mb-2">Invite Guests Directly</h3>
                    <p className="text-sm text-gray-600">
                      We'll help you reach out to your guests through multiple channels after event creation.
                    </p>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </motion.div>
        );

      case 7:
        const selectedPkg = packages.find(p => p.id === selectedPackage);
        return (
          <motion.div
            key="step7"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            className="space-y-4"
          >
            <h2 className="text-xl font-bold text-gray-900 mb-4">Summary</h2>
            
            <div className="space-y-3">
              <div className="bg-white rounded-2xl p-5 shadow-lg">
                <h3 className="font-bold text-gray-900 mb-3">Package</h3>
                <p className="text-sm text-gray-600">
                  {selectedPkg?.name} - ${selectedPkg?.price}
                </p>
              </div>

              <div className="bg-white rounded-2xl p-5 shadow-lg">
                <h3 className="font-bold text-gray-900 mb-3">Venue</h3>
                <p className="text-sm text-gray-600">
                  {selectedVenue ? venues.find(v => v.id === selectedVenue)?.name : customVenue.name}
                </p>
              </div>

              <div className="bg-white rounded-2xl p-5 shadow-lg">
                <h3 className="font-bold text-gray-900 mb-3">Event Type</h3>
                <p className="text-sm text-gray-600">
                  {selectedEventType ? eventTypes.find(t => t.id === selectedEventType)?.name : customEventType}
                </p>
              </div>

              <div className="bg-white rounded-2xl p-5 shadow-lg">
                <h3 className="font-bold text-gray-900 mb-3">Template</h3>
                <p className="text-sm text-gray-600">
                  {requestCustomTemplate ? 'Custom Template (Requested)' : templates.find(t => t.id === selectedTemplate)?.name}
                </p>
              </div>

              <div className="bg-white rounded-2xl p-5 shadow-lg">
                <h3 className="font-bold text-gray-900 mb-3">Event Details</h3>
                <div className="space-y-2 text-sm text-gray-600">
                  <p><span className="font-semibold">Name:</span> {eventDetails.name}</p>
                  <p><span className="font-semibold">Date:</span> {eventDetails.date} at {eventDetails.time}</p>
                  <p><span className="font-semibold">RSVP Deadline:</span> {eventDetails.responseDeadline}</p>
                  <p><span className="font-semibold">Companions:</span> {eventDetails.allowCompanions ? `Allowed (max ${eventDetails.maxCompanions})` : 'Not allowed'}</p>
                </div>
              </div>

              <div className="bg-white rounded-2xl p-5 shadow-lg">
                <h3 className="font-bold text-gray-900 mb-3">Guests</h3>
                <div className="space-y-2 text-sm">
                  {guestMethod === 'invite' && (
                    <p className="text-gray-600">Guests will be reached via WhatsApp, Email & SMS</p>
                  )}
                  {guestMethod === 'excel' && excelFile && (
                    <p className="text-gray-600">Excel file uploaded: {excelFile.name}</p>
                  )}
                  {guestMethod === 'manual' && manualGuests.length > 0 && (
                    <>
                      <p className="text-gray-600 font-semibold mb-2">{manualGuests.length} guests added</p>
                      <div className="max-h-40 overflow-y-auto space-y-2">
                        {manualGuests.map((guest, index) => (
                          <div key={index} className="text-xs bg-gray-50 rounded-lg p-2">
                            <p className="font-medium text-gray-900">{guest.name}</p>
                            <p className="text-gray-600">{guest.email}</p>
                          </div>
                        ))}
                      </div>
                    </>
                  )}
                </div>
              </div>
            </div>
          </motion.div>
        );

      default:
        return null;
    }
  };

  const canProceed = () => {
    switch (currentStep) {
      case 1: return canProceedStep1;
      case 2: return canProceedStep2;
      case 3: return canProceedStep3;
      case 4: return canProceedStep4;
      case 5: return canProceedStep5;
      case 6: return canProceedStep6;
      case 7: return true;
      default: return false;
    }
  };

  return (
    <div className="min-h-screen pb-6">
      {/* Header */}
      <motion.div 
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-gradient-to-br from-purple-600 via-pink-600 to-rose-600 text-white px-6 pt-12 pb-8 relative overflow-hidden"
      >
        <motion.div
          animate={{
            scale: [1, 1.5, 1],
            x: [-50, 50, -50],
          }}
          transition={{
            duration: 10,
            repeat: Infinity,
            ease: "easeInOut"
          }}
          className="absolute top-0 right-0 w-40 h-40 bg-white/10 rounded-full blur-3xl"
        />

        <div className="relative z-10">
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ type: "spring", delay: 0.2 }}
            className="inline-flex items-center gap-2 bg-white/20 backdrop-blur-sm px-3 py-1.5 rounded-full mb-3"
          >
            <Sparkles className="w-3.5 h-3.5" />
            <span className="text-xs font-medium">Step {currentStep} of {totalSteps}</span>
          </motion.div>
          <h1 className="text-3xl font-bold">Create Event</h1>
          <p className="text-purple-100 text-sm mt-2">Let's make something amazing</p>

          {/* Progress Bar */}
          <div className="mt-6 space-y-2">
            <div className="flex justify-between text-xs text-purple-100">
              <span>Progress</span>
              <span>{Math.round((currentStep / totalSteps) * 100)}%</span>
            </div>
            <div className="h-2 bg-white/20 rounded-full overflow-hidden">
              <motion.div
                initial={{ width: 0 }}
                animate={{ width: `${(currentStep / totalSteps) * 100}%` }}
                transition={{ duration: 0.5 }}
                className="h-full bg-white rounded-full shadow-lg"
              />
            </div>
          </div>
        </div>
      </motion.div>

      {/* Content */}
      <div className="px-6 py-6">
        <AnimatePresence mode="wait">
          {renderStepContent()}
        </AnimatePresence>
      </div>

      {/* Navigation Buttons */}
      <div className="fixed bottom-24 left-0 right-0 px-6 max-w-[393px] mx-auto">
        <div className="bg-white/80 backdrop-blur-xl rounded-3xl p-4 shadow-2xl">
          {currentStep === totalSteps ? (
            <div className="flex gap-2">
              <motion.button
                whileTap={{ scale: 0.95 }}
                onClick={handleSaveDraft}
                className="flex-1 py-3.5 bg-gray-200 text-gray-700 rounded-2xl font-bold"
              >
                Save as Draft
              </motion.button>
              <motion.button
                whileTap={{ scale: 0.95 }}
                onClick={handleSubmit}
                className="flex-1 py-3.5 bg-gradient-to-r from-purple-600 to-pink-600 text-white rounded-2xl font-bold shadow-lg"
              >
                Submit & Pay
              </motion.button>
            </div>
          ) : (
            <div className="flex gap-2">
              {currentStep > 1 && (
                <motion.button
                  whileTap={{ scale: 0.95 }}
                  onClick={handleBack}
                  className="w-14 h-14 bg-gray-100 rounded-2xl flex items-center justify-center"
                >
                  <ArrowLeft className="w-6 h-6 text-gray-700" />
                </motion.button>
              )}
              <motion.button
                whileTap={{ scale: canProceed() ? 0.95 : 1 }}
                onClick={canProceed() ? handleNext : undefined}
                disabled={!canProceed()}
                className={`flex-1 py-3.5 rounded-2xl font-bold flex items-center justify-center gap-2 transition-all ${
                  canProceed()
                    ? 'bg-gradient-to-r from-purple-600 to-pink-600 text-white shadow-lg'
                    : 'bg-gray-200 text-gray-400'
                }`}
              >
                Continue
                <ArrowRight className="w-5 h-5" />
              </motion.button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
