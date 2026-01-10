import { Camera, Check, X, Users, MapPin, Calendar, Clock, Search, CheckCircle, XCircle } from 'lucide-react';
import { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';

export function QRScanner() {
  const [isScanning, setIsScanning] = useState(false);
  const [scannedGuest, setScannedGuest] = useState<any>(null);
  const [showGuestList, setShowGuestList] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');

  // Mock event data
  const event = {
    name: 'Wedding Ceremony',
    venue: 'Grand Hotel Ballroom',
    date: '2026-01-15',
    time: '18:00',
  };

  // Mock guests data
  const guests = [
    { id: '1', name: 'Ahmed Al-Saud', status: 'attending', companions: 2, checkedIn: true, qrCode: 'QR123456' },
    { id: '2', name: 'Fatima Al-Rashid', status: 'attending', companions: 1, checkedIn: true, qrCode: 'QR234567' },
    { id: '3', name: 'Mohammed Al-Harbi', status: 'attending', companions: 3, checkedIn: false, qrCode: 'QR345678' },
    { id: '4', name: 'Sara Al-Qahtani', status: 'attending', companions: 0, checkedIn: false, qrCode: 'QR456789' },
    { id: '5', name: 'Khalid Al-Mutairi', status: 'attending', companions: 2, checkedIn: false, qrCode: 'QR567890' },
    { id: '6', name: 'Noura Al-Dosari', status: 'not_attending', companions: 0, checkedIn: false, qrCode: 'QR678901' },
    { id: '7', name: 'Abdullah Al-Zahrani', status: 'attending', companions: 1, checkedIn: false, qrCode: 'QR789012' },
    { id: '8', name: 'Layla Al-Ghamdi', status: 'attending', companions: 2, checkedIn: false, qrCode: 'QR890123' },
  ];

  const filteredGuests = guests.filter(guest =>
    guest.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const attendingGuests = guests.filter(g => g.status === 'attending');
  const checkedInGuests = guests.filter(g => g.checkedIn);

  const handleScan = () => {
    setIsScanning(true);
    // Simulate scanning
    setTimeout(() => {
      // Random guest for demo
      const randomGuest = guests[Math.floor(Math.random() * guests.length)];
      setScannedGuest(randomGuest);
      setIsScanning(false);
    }, 2000);
  };

  const handleCheckIn = (guestId: string) => {
    // Update guest check-in status
    const guest = guests.find(g => g.id === guestId);
    if (guest) {
      guest.checkedIn = true;
    }
    setScannedGuest(null);
  };

  const handleReject = () => {
    setScannedGuest(null);
  };

  return (
    <div className="min-h-screen pb-6">
      {/* Header */}
      <motion.div 
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-gradient-to-br from-indigo-600 via-purple-600 to-pink-600 text-white px-6 pt-12 pb-8 relative overflow-hidden"
      >
        <motion.div
          animate={{
            scale: [1, 1.4, 1],
            rotate: [0, 180, 0],
          }}
          transition={{
            duration: 15,
            repeat: Infinity,
            ease: "linear"
          }}
          className="absolute -top-10 -right-10 w-40 h-40 bg-white/10 rounded-full blur-3xl"
        />

        <div className="relative z-10">
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ type: "spring", delay: 0.2 }}
            className="inline-flex items-center gap-2 bg-white/20 backdrop-blur-sm px-3 py-1.5 rounded-full mb-3"
          >
            <Camera className="w-3.5 h-3.5" />
            <span className="text-xs font-medium">QR Scanner</span>
          </motion.div>
          <h1 className="text-3xl font-bold">{event.name}</h1>
          <p className="text-purple-100 text-sm mt-2">Scan guest QR codes for check-in</p>

          {/* Stats */}
          <div className="grid grid-cols-3 gap-3 mt-6">
            <div className="bg-white/20 backdrop-blur-sm rounded-2xl p-3">
              <p className="text-2xl font-bold">{attendingGuests.length}</p>
              <p className="text-xs text-purple-100">Expected</p>
            </div>
            <div className="bg-white/20 backdrop-blur-sm rounded-2xl p-3">
              <p className="text-2xl font-bold">{checkedInGuests.length}</p>
              <p className="text-xs text-purple-100">Checked In</p>
            </div>
            <div className="bg-white/20 backdrop-blur-sm rounded-2xl p-3">
              <p className="text-2xl font-bold">{attendingGuests.length - checkedInGuests.length}</p>
              <p className="text-xs text-purple-100">Pending</p>
            </div>
          </div>
        </div>
      </motion.div>

      {/* Scanner Button */}
      <div className="px-6 -mt-8 relative z-20">
        <motion.button
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
          onClick={handleScan}
          disabled={isScanning}
          className="w-full bg-gradient-to-br from-purple-600 to-pink-600 text-white rounded-3xl p-6 shadow-2xl flex items-center justify-center gap-3"
        >
          {isScanning ? (
            <>
              <motion.div
                animate={{ rotate: 360 }}
                transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
              >
                <Camera className="w-8 h-8" />
              </motion.div>
              <span className="text-lg font-bold">Scanning...</span>
            </>
          ) : (
            <>
              <Camera className="w-8 h-8" />
              <span className="text-lg font-bold">Scan QR Code</span>
            </>
          )}
        </motion.button>
      </div>

      {/* Scanned Guest Modal */}
      <AnimatePresence>
        {scannedGuest && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-6"
            onClick={handleReject}
          >
            <motion.div
              initial={{ scale: 0.8, y: 50 }}
              animate={{ scale: 1, y: 0 }}
              exit={{ scale: 0.8, y: 50 }}
              onClick={(e) => e.stopPropagation()}
              className="bg-white rounded-3xl p-6 max-w-sm w-full shadow-2xl"
            >
              {scannedGuest.status === 'attending' && !scannedGuest.checkedIn ? (
                <>
                  <motion.div
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    transition={{ type: "spring", delay: 0.2 }}
                    className="w-20 h-20 bg-gradient-to-br from-green-500 to-emerald-500 rounded-full flex items-center justify-center mx-auto mb-4"
                  >
                    <Check className="w-10 h-10 text-white" />
                  </motion.div>
                  <h2 className="text-2xl font-bold text-gray-900 text-center mb-2">Guest Verified</h2>
                  <div className="bg-gray-50 rounded-2xl p-4 mb-4 space-y-3">
                    <div>
                      <p className="text-sm text-gray-600">Guest Name</p>
                      <p className="text-lg font-bold text-gray-900">{scannedGuest.name}</p>
                    </div>
                    <div className="flex items-center gap-2 text-sm text-gray-600">
                      <Calendar className="w-4 h-4" />
                      <span>{new Date(event.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}</span>
                    </div>
                    <div className="flex items-center gap-2 text-sm text-gray-600">
                      <Clock className="w-4 h-4" />
                      <span>{event.time}</span>
                    </div>
                    <div className="flex items-center gap-2 text-sm text-gray-600">
                      <MapPin className="w-4 h-4" />
                      <span>{event.venue}</span>
                    </div>
                    <div className="flex items-center gap-2 text-sm text-gray-600">
                      <Users className="w-4 h-4" />
                      <span>{scannedGuest.companions} Companion{scannedGuest.companions !== 1 ? 's' : ''}</span>
                    </div>
                  </div>
                  <div className="flex gap-2">
                    <motion.button
                      whileTap={{ scale: 0.95 }}
                      onClick={handleReject}
                      className="flex-1 py-3 bg-gray-100 text-gray-700 rounded-2xl font-bold"
                    >
                      Cancel
                    </motion.button>
                    <motion.button
                      whileTap={{ scale: 0.95 }}
                      onClick={() => handleCheckIn(scannedGuest.id)}
                      className="flex-1 py-3 bg-gradient-to-r from-green-600 to-emerald-600 text-white rounded-2xl font-bold shadow-lg"
                    >
                      Check In
                    </motion.button>
                  </div>
                </>
              ) : (
                <>
                  <motion.div
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    transition={{ type: "spring", delay: 0.2 }}
                    className="w-20 h-20 bg-gradient-to-br from-red-500 to-rose-500 rounded-full flex items-center justify-center mx-auto mb-4"
                  >
                    <X className="w-10 h-10 text-white" />
                  </motion.div>
                  <h2 className="text-2xl font-bold text-gray-900 text-center mb-2">Access Denied</h2>
                  <div className="bg-red-50 rounded-2xl p-4 mb-4">
                    <p className="text-center font-bold text-gray-900 mb-2">{scannedGuest.name}</p>
                    <p className="text-sm text-center text-gray-600">
                      {scannedGuest.checkedIn ? 'Already checked in' : 'Not attending this event'}
                    </p>
                  </div>
                  <motion.button
                    whileTap={{ scale: 0.95 }}
                    onClick={handleReject}
                    className="w-full py-3 bg-gray-900 text-white rounded-2xl font-bold"
                  >
                    Close
                  </motion.button>
                </>
              )}
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Guest List */}
      <div className="px-6 mt-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-bold text-gray-900">Guest List</h2>
          <button
            onClick={() => setShowGuestList(!showGuestList)}
            className="text-sm text-purple-600 font-semibold"
          >
            {showGuestList ? 'Hide' : 'Show'}
          </button>
        </div>

        {showGuestList && (
          <>
            {/* Search */}
            <div className="relative mb-4">
              <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
              <input
                type="text"
                placeholder="Search guests..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-12 pr-4 py-3 bg-white border-2 border-gray-100 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-purple-600"
              />
            </div>

            {/* Guest Cards */}
            <motion.div 
              initial="hidden"
              animate="show"
              variants={{
                hidden: { opacity: 0 },
                show: {
                  opacity: 1,
                  transition: { staggerChildren: 0.05 }
                }
              }}
              className="space-y-3"
            >
              {filteredGuests.map((guest, index) => (
                <motion.div
                  key={guest.id}
                  variants={{
                    hidden: { opacity: 0, x: -20 },
                    show: { opacity: 1, x: 0 }
                  }}
                  whileHover={{ scale: 1.02 }}
                  className={`bg-white rounded-2xl p-4 shadow-lg ${
                    guest.checkedIn ? 'border-2 border-green-200' : ''
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className={`w-12 h-12 rounded-full flex items-center justify-center text-white font-bold ${
                        guest.checkedIn 
                          ? 'bg-gradient-to-br from-green-500 to-emerald-500'
                          : guest.status === 'attending'
                          ? 'bg-gradient-to-br from-purple-500 to-pink-500'
                          : 'bg-gradient-to-br from-gray-400 to-gray-500'
                      }`}>
                        {guest.checkedIn ? (
                          <CheckCircle className="w-6 h-6" />
                        ) : guest.status === 'attending' ? (
                          guest.name.charAt(0)
                        ) : (
                          <XCircle className="w-6 h-6" />
                        )}
                      </div>
                      <div>
                        <h3 className="font-bold text-gray-900">{guest.name}</h3>
                        <div className="flex items-center gap-2 mt-1">
                          {guest.companions > 0 && (
                            <span className="text-xs bg-purple-100 text-purple-700 px-2 py-0.5 rounded-full">
                              +{guest.companions}
                            </span>
                          )}
                          {guest.checkedIn && (
                            <span className="text-xs bg-green-100 text-green-700 px-2 py-0.5 rounded-full">
                              Checked In
                            </span>
                          )}
                        </div>
                      </div>
                    </div>
                    {!guest.checkedIn && guest.status === 'attending' && (
                      <motion.button
                        whileTap={{ scale: 0.9 }}
                        onClick={() => handleCheckIn(guest.id)}
                        className="px-4 py-2 bg-purple-600 text-white rounded-xl text-sm font-bold"
                      >
                        Check In
                      </motion.button>
                    )}
                  </div>
                </motion.div>
              ))}
            </motion.div>
          </>
        )}
      </div>
    </div>
  );
}
