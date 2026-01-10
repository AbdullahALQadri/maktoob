import { MapPin, Phone, Mail, Plus, Search, ArrowRight, Building2, Users } from 'lucide-react';
import { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';

export function Venue() {
  const [searchQuery, setSearchQuery] = useState('');
  const [showAddVenue, setShowAddVenue] = useState(false);
  const [newVenue, setNewVenue] = useState({
    name: '',
    address: '',
    phone: '',
    email: '',
    capacity: '',
  });

  const venues = [
    {
      id: 1,
      name: 'Grand Hotel Ballroom',
      address: 'King Fahd Road, Riyadh',
      phone: '+966 11 234 5678',
      email: 'events@grandhotel.com',
      capacity: 300,
      events: 8,
      gradient: 'from-purple-500 to-pink-500',
      icon: '🏨',
    },
    {
      id: 2,
      name: 'Convention Center',
      address: 'Olaya Street, Riyadh',
      phone: '+966 11 345 6789',
      email: 'info@conventioncenter.com',
      capacity: 500,
      events: 12,
      gradient: 'from-blue-500 to-cyan-500',
      icon: '🏢',
    },
    {
      id: 3,
      name: 'Beach Resort',
      address: 'Corniche, Jeddah',
      phone: '+966 12 456 7890',
      email: 'bookings@beachresort.com',
      capacity: 150,
      events: 5,
      gradient: 'from-amber-500 to-orange-500',
      icon: '🏖️',
    },
    {
      id: 4,
      name: 'University Hall',
      address: 'University District, Riyadh',
      phone: '+966 11 567 8901',
      email: 'hall@university.edu.sa',
      capacity: 400,
      events: 3,
      gradient: 'from-green-500 to-emerald-500',
      icon: '🎓',
    },
  ];

  const filteredVenues = venues.filter(venue =>
    venue.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    venue.address.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleAddVenue = () => {
    setShowAddVenue(false);
    setNewVenue({ name: '', address: '', phone: '', email: '', capacity: '' });
  };

  const container = {
    hidden: { opacity: 0 },
    show: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1
      }
    }
  };

  const item = {
    hidden: { y: 20, opacity: 0 },
    show: { y: 0, opacity: 1 }
  };

  return (
    <div className="min-h-screen">
      {/* Header */}
      <motion.div 
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-gradient-to-br from-green-600 via-emerald-600 to-teal-600 text-white px-6 pt-12 pb-8 relative overflow-hidden"
      >
        <motion.div
          animate={{
            scale: [1, 1.4, 1],
            rotate: [0, 180, 360],
          }}
          transition={{
            duration: 12,
            repeat: Infinity,
            ease: "linear"
          }}
          className="absolute -top-10 -left-10 w-40 h-40 bg-white/10 rounded-full blur-3xl"
        />

        <div className="relative z-10">
          <div className="flex items-center justify-between mb-6">
            <div>
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ type: "spring", delay: 0.2 }}
                className="inline-flex items-center gap-2 bg-white/20 backdrop-blur-sm px-3 py-1.5 rounded-full mb-3"
              >
                <Building2 className="w-3.5 h-3.5" />
                <span className="text-xs font-medium">{filteredVenues.length} Venues</span>
              </motion.div>
              <h1 className="text-3xl font-bold">Venues</h1>
              <p className="text-green-100 text-sm mt-2">Manage your event locations</p>
            </div>
            <motion.button
              whileHover={{ scale: 1.1, rotate: 90 }}
              whileTap={{ scale: 0.9 }}
              onClick={() => setShowAddVenue(!showAddVenue)}
              className="w-14 h-14 bg-white text-green-600 rounded-2xl flex items-center justify-center shadow-xl"
            >
              <Plus className="w-6 h-6" strokeWidth={2.5} />
            </motion.button>
          </div>
          
          {/* Search Bar */}
          <motion.div 
            initial={{ scale: 0.9, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            transition={{ delay: 0.2 }}
            className="relative"
          >
            <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-green-300" />
            <input
              type="text"
              placeholder="Search venues..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-12 pr-4 py-3.5 bg-white/20 backdrop-blur-md border border-white/30 rounded-2xl text-white placeholder-green-200 focus:outline-none focus:ring-2 focus:ring-white/50 focus:bg-white/30 transition-all"
            />
          </motion.div>
        </div>
      </motion.div>

      {/* Add Venue Form */}
      <AnimatePresence>
        {showAddVenue && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            className="overflow-hidden"
          >
            <div className="px-6 py-6">
              <motion.div
                initial={{ y: -20 }}
                animate={{ y: 0 }}
                className="bg-white rounded-3xl p-6 shadow-xl"
              >
                <h2 className="font-bold text-gray-900 mb-5 text-lg">Add New Venue</h2>
                
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">Venue Name</label>
                    <input
                      type="text"
                      placeholder="Enter venue name"
                      value={newVenue.name}
                      onChange={(e) => setNewVenue({ ...newVenue, name: e.target.value })}
                      className="w-full px-4 py-3.5 bg-gray-50 border-2 border-gray-100 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-green-600 focus:border-transparent transition-all"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">Address</label>
                    <input
                      type="text"
                      placeholder="Enter address"
                      value={newVenue.address}
                      onChange={(e) => setNewVenue({ ...newVenue, address: e.target.value })}
                      className="w-full px-4 py-3.5 bg-gray-50 border-2 border-gray-100 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-green-600 focus:border-transparent transition-all"
                    />
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block text-sm font-semibold text-gray-700 mb-2">Phone</label>
                      <input
                        type="tel"
                        placeholder="+966"
                        value={newVenue.phone}
                        onChange={(e) => setNewVenue({ ...newVenue, phone: e.target.value })}
                        className="w-full px-4 py-3.5 bg-gray-50 border-2 border-gray-100 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-green-600 focus:border-transparent transition-all"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-semibold text-gray-700 mb-2">Capacity</label>
                      <input
                        type="number"
                        placeholder="Max guests"
                        value={newVenue.capacity}
                        onChange={(e) => setNewVenue({ ...newVenue, capacity: e.target.value })}
                        className="w-full px-4 py-3.5 bg-gray-50 border-2 border-gray-100 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-green-600 focus:border-transparent transition-all"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">Email</label>
                    <input
                      type="email"
                      placeholder="venue@example.com"
                      value={newVenue.email}
                      onChange={(e) => setNewVenue({ ...newVenue, email: e.target.value })}
                      className="w-full px-4 py-3.5 bg-gray-50 border-2 border-gray-100 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-green-600 focus:border-transparent transition-all"
                    />
                  </div>

                  <div className="flex gap-2 mt-6">
                    <motion.button
                      whileTap={{ scale: 0.95 }}
                      onClick={() => setShowAddVenue(false)}
                      className="flex-1 py-3.5 bg-gray-100 text-gray-700 rounded-2xl font-bold"
                    >
                      Cancel
                    </motion.button>
                    <motion.button
                      whileTap={{ scale: 0.95 }}
                      onClick={handleAddVenue}
                      className="flex-1 py-3.5 bg-gradient-to-r from-green-600 to-emerald-600 text-white rounded-2xl font-bold shadow-lg"
                    >
                      Add Venue
                    </motion.button>
                  </div>
                </div>
              </motion.div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Venues List */}
      <motion.div 
        variants={container}
        initial="hidden"
        animate="show"
        className="px-6 py-6 space-y-4"
      >
        {filteredVenues.map((venue, index) => (
          <motion.div
            key={venue.id}
            variants={item}
            whileHover={{ scale: 1.02, y: -4 }}
            whileTap={{ scale: 0.98 }}
            className="bg-white rounded-3xl p-6 shadow-xl shadow-gray-200/50 relative overflow-hidden"
          >
            {/* Gradient Background */}
            <div className={`absolute -top-10 -right-10 w-32 h-32 bg-gradient-to-br ${venue.gradient} opacity-10 rounded-full blur-2xl`} />
            
            <div className="relative z-10">
              <div className="flex justify-between items-start mb-4">
                <div className="flex items-start gap-3">
                  <motion.div 
                    whileHover={{ rotate: 360, scale: 1.1 }}
                    transition={{ duration: 0.5 }}
                    className={`w-14 h-14 rounded-2xl bg-gradient-to-br ${venue.gradient} flex items-center justify-center text-2xl shadow-lg`}
                  >
                    {venue.icon}
                  </motion.div>
                  <div>
                    <h3 className="font-bold text-gray-900 text-lg">{venue.name}</h3>
                    <div className="flex items-center gap-1.5 mt-1.5 text-sm text-gray-600">
                      <MapPin className="w-3.5 h-3.5" />
                      <span>{venue.address}</span>
                    </div>
                  </div>
                </div>
                <motion.div
                  whileHover={{ x: 5, scale: 1.2 }}
                  className="text-purple-600"
                >
                  <ArrowRight className="w-5 h-5" />
                </motion.div>
              </div>

              <div className="space-y-3 mb-4">
                <div className="flex items-center gap-3 text-sm text-gray-600">
                  <div className="w-8 h-8 rounded-xl bg-blue-50 flex items-center justify-center">
                    <Phone className="w-4 h-4 text-blue-600" />
                  </div>
                  <span className="font-medium">{venue.phone}</span>
                </div>
                <div className="flex items-center gap-3 text-sm text-gray-600">
                  <div className="w-8 h-8 rounded-xl bg-purple-50 flex items-center justify-center">
                    <Mail className="w-4 h-4 text-purple-600" />
                  </div>
                  <span className="font-medium">{venue.email}</span>
                </div>
              </div>

              {/* Stats */}
              <div className="flex gap-3 pt-4 border-t border-gray-100">
                <motion.div 
                  whileHover={{ scale: 1.05 }}
                  className="flex-1 bg-gradient-to-br from-purple-50 to-pink-50 rounded-2xl p-4 text-center"
                >
                  <div className="flex items-center justify-center gap-1 mb-1">
                    <Users className="w-4 h-4 text-purple-600" />
                    <p className="text-2xl font-bold text-gray-900">{venue.capacity}</p>
                  </div>
                  <p className="text-xs text-gray-600 font-medium">Capacity</p>
                </motion.div>
                <motion.div 
                  whileHover={{ scale: 1.05 }}
                  className="flex-1 bg-gradient-to-br from-blue-50 to-cyan-50 rounded-2xl p-4 text-center"
                >
                  <div className="flex items-center justify-center gap-1 mb-1">
                    <Building2 className="w-4 h-4 text-blue-600" />
                    <p className="text-2xl font-bold text-blue-600">{venue.events}</p>
                  </div>
                  <p className="text-xs text-gray-600 font-medium">Events</p>
                </motion.div>
              </div>
            </div>
          </motion.div>
        ))}
      </motion.div>
    </div>
  );
}
