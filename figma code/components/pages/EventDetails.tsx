import { ArrowLeft, Calendar, MapPin, Users, Clock, CheckCircle, XCircle, Mail, Phone, Search, Download, Share2, Edit, Trash2 } from 'lucide-react';
import { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';

interface EventDetailsProps {
  eventId: string;
  onBack: () => void;
}

export function EventDetails({ eventId, onBack }: EventDetailsProps) {
  const [activeTab, setActiveTab] = useState('overview');
  const [searchQuery, setSearchQuery] = useState('');

  // Mock event data
  const event = {
    id: eventId,
    name: 'Wedding Ceremony',
    type: 'Wedding',
    date: '2026-01-15',
    time: '18:00',
    venue: 'Grand Hotel Ballroom',
    venueAddress: '123 Main Street, City',
    description: 'Join us for a beautiful celebration of love and commitment.',
    package: 'Gold',
    packagePrice: '599',
    invitations: 300,
    responses: 180,
    attending: 150,
    declined: 30,
    pending: 120,
    status: 'active',
    gradient: 'from-pink-500 to-rose-500',
    icon: '💒',
    template: 'Elegant Gold',
    responseDeadline: '2026-01-10',
    allowCompanions: true,
    maxCompanions: 2,
  };

  const guests = [
    { id: '1', name: 'John Doe', email: 'john@example.com', phone: '+1234567890', status: 'attending', companions: 1, checkedIn: false },
    { id: '2', name: 'Jane Smith', email: 'jane@example.com', phone: '+1234567891', status: 'attending', companions: 2, checkedIn: true },
    { id: '3', name: 'Bob Johnson', email: 'bob@example.com', phone: '+1234567892', status: 'declined', companions: 0, checkedIn: false },
    { id: '4', name: 'Alice Williams', email: 'alice@example.com', phone: '+1234567893', status: 'pending', companions: 0, checkedIn: false },
    { id: '5', name: 'Charlie Brown', email: 'charlie@example.com', phone: '+1234567894', status: 'attending', companions: 1, checkedIn: true },
    { id: '6', name: 'Diana Prince', email: 'diana@example.com', phone: '+1234567895', status: 'attending', companions: 0, checkedIn: false },
  ];

  const filteredGuests = guests.filter(guest =>
    guest.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    guest.email.toLowerCase().includes(searchQuery.toLowerCase()) ||
    guest.phone.includes(searchQuery)
  );

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'attending':
        return 'bg-green-500';
      case 'declined':
        return 'bg-red-500';
      case 'pending':
        return 'bg-yellow-500';
      default:
        return 'bg-gray-400';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'attending':
        return <CheckCircle className="w-4 h-4 text-green-600" />;
      case 'declined':
        return <XCircle className="w-4 h-4 text-red-600" />;
      default:
        return <Clock className="w-4 h-4 text-yellow-600" />;
    }
  };

  return (
    <div className="min-h-screen pb-24">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className={`bg-gradient-to-br ${event.gradient} text-white px-6 pt-12 pb-6 relative overflow-hidden`}
      >
        <motion.div
          animate={{
            scale: [1, 1.3, 1],
            rotate: [0, 90, 0],
          }}
          transition={{
            duration: 15,
            repeat: Infinity,
            ease: "linear"
          }}
          className="absolute -top-10 -right-10 w-40 h-40 bg-white/10 rounded-full blur-3xl"
        />

        <div className="relative z-10">
          <motion.button
            whileTap={{ scale: 0.95 }}
            onClick={onBack}
            className="flex items-center gap-2 text-white/90 mb-4"
          >
            <ArrowLeft className="w-5 h-5" />
            <span className="text-sm font-medium">Back to Events</span>
          </motion.button>

          <div className="flex items-start gap-4 mb-4">
            <div className="text-4xl">{event.icon}</div>
            <div className="flex-1">
              <h1 className="text-2xl font-bold mb-2">{event.name}</h1>
              <div className="flex items-center gap-2">
                <span className="text-xs px-3 py-1 bg-white/20 backdrop-blur-sm rounded-full">
                  {event.type}
                </span>
                <span className="text-xs px-3 py-1 bg-white/20 backdrop-blur-sm rounded-full capitalize">
                  {event.status}
                </span>
              </div>
            </div>
          </div>

          {/* Quick Stats */}
          <div className="grid grid-cols-3 gap-3 mt-6">
            <div className="bg-white/10 backdrop-blur-md rounded-xl p-3">
              <p className="text-xs text-white/80 mb-1">Invited</p>
              <p className="text-xl font-bold">{event.invitations}</p>
            </div>
            <div className="bg-white/10 backdrop-blur-md rounded-xl p-3">
              <p className="text-xs text-white/80 mb-1">Attending</p>
              <p className="text-xl font-bold text-green-300">{event.attending}</p>
            </div>
            <div className="bg-white/10 backdrop-blur-md rounded-xl p-3">
              <p className="text-xs text-white/80 mb-1">Declined</p>
              <p className="text-xl font-bold text-red-300">{event.declined}</p>
            </div>
          </div>
        </div>
      </motion.div>

      {/* Tabs */}
      <div className="px-6 py-4 bg-white border-b border-gray-200 sticky top-0 z-10">
        <div className="flex gap-2 overflow-x-auto scrollbar-hide">
          {['overview', 'guests', 'details'].map((tab) => (
            <motion.button
              key={tab}
              onClick={() => setActiveTab(tab)}
              whileTap={{ scale: 0.95 }}
              className={`px-5 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all ${
                activeTab === tab
                  ? 'bg-gradient-to-r from-purple-600 to-pink-600 text-white shadow-lg'
                  : 'bg-gray-100 text-gray-600'
              }`}
            >
              {tab.charAt(0).toUpperCase() + tab.slice(1)}
            </motion.button>
          ))}
        </div>
      </div>

      {/* Content */}
      <div className="px-6 py-6">
        <AnimatePresence mode="wait">
          {/* Overview Tab */}
          {activeTab === 'overview' && (
            <motion.div
              key="overview"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              className="space-y-4"
            >
              {/* Event Info */}
              <div className="bg-white rounded-2xl p-5 shadow-lg space-y-4">
                <h3 className="font-bold text-gray-900 mb-3">Event Information</h3>
                
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center">
                    <Calendar className="w-5 h-5 text-blue-600" />
                  </div>
                  <div>
                    <p className="text-xs text-gray-500">Date & Time</p>
                    <p className="font-medium text-gray-900">{new Date(event.date).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })} at {event.time}</p>
                  </div>
                </div>

                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-purple-50 flex items-center justify-center">
                    <MapPin className="w-5 h-5 text-purple-600" />
                  </div>
                  <div>
                    <p className="text-xs text-gray-500">Venue</p>
                    <p className="font-medium text-gray-900">{event.venue}</p>
                    <p className="text-xs text-gray-600">{event.venueAddress}</p>
                  </div>
                </div>

                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-green-50 flex items-center justify-center">
                    <Clock className="w-5 h-5 text-green-600" />
                  </div>
                  <div>
                    <p className="text-xs text-gray-500">RSVP Deadline</p>
                    <p className="font-medium text-gray-900">{new Date(event.responseDeadline).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })}</p>
                  </div>
                </div>
              </div>

              {/* Response Analytics */}
              <div className="bg-white rounded-2xl p-5 shadow-lg">
                <h3 className="font-bold text-gray-900 mb-4">Response Analytics</h3>
                
                <div className="space-y-4">
                  {/* Attending */}
                  <div>
                    <div className="flex justify-between text-sm mb-2">
                      <span className="text-gray-600 font-medium">Attending</span>
                      <span className="font-bold text-green-600">{event.attending} ({Math.round((event.attending / event.invitations) * 100)}%)</span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2.5 overflow-hidden">
                      <motion.div 
                        initial={{ width: 0 }}
                        animate={{ width: `${(event.attending / event.invitations) * 100}%` }}
                        transition={{ delay: 0.2, duration: 0.8 }}
                        className="bg-gradient-to-r from-green-500 to-emerald-500 h-2.5 rounded-full"
                      />
                    </div>
                  </div>

                  {/* Declined */}
                  <div>
                    <div className="flex justify-between text-sm mb-2">
                      <span className="text-gray-600 font-medium">Declined</span>
                      <span className="font-bold text-red-600">{event.declined} ({Math.round((event.declined / event.invitations) * 100)}%)</span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2.5 overflow-hidden">
                      <motion.div 
                        initial={{ width: 0 }}
                        animate={{ width: `${(event.declined / event.invitations) * 100}%` }}
                        transition={{ delay: 0.4, duration: 0.8 }}
                        className="bg-gradient-to-r from-red-500 to-rose-500 h-2.5 rounded-full"
                      />
                    </div>
                  </div>

                  {/* Pending */}
                  <div>
                    <div className="flex justify-between text-sm mb-2">
                      <span className="text-gray-600 font-medium">Pending</span>
                      <span className="font-bold text-yellow-600">{event.pending} ({Math.round((event.pending / event.invitations) * 100)}%)</span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2.5 overflow-hidden">
                      <motion.div 
                        initial={{ width: 0 }}
                        animate={{ width: `${(event.pending / event.invitations) * 100}%` }}
                        transition={{ delay: 0.6, duration: 0.8 }}
                        className="bg-gradient-to-r from-yellow-500 to-amber-500 h-2.5 rounded-full"
                      />
                    </div>
                  </div>
                </div>
              </div>

              {/* Actions */}
              <div className="grid grid-cols-2 gap-3">
                <motion.button
                  whileTap={{ scale: 0.95 }}
                  className="flex items-center justify-center gap-2 bg-white px-4 py-3 rounded-xl shadow-lg text-gray-700 font-medium"
                >
                  <Share2 className="w-4 h-4" />
                  Share
                </motion.button>
                <motion.button
                  whileTap={{ scale: 0.95 }}
                  className="flex items-center justify-center gap-2 bg-white px-4 py-3 rounded-xl shadow-lg text-gray-700 font-medium"
                >
                  <Download className="w-4 h-4" />
                  Export
                </motion.button>
              </div>
            </motion.div>
          )}

          {/* Guests Tab */}
          {activeTab === 'guests' && (
            <motion.div
              key="guests"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              className="space-y-4"
            >
              {/* Search */}
              <div className="relative">
                <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input
                  type="text"
                  placeholder="Search guests..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full pl-12 pr-4 py-3.5 bg-white border-2 border-gray-100 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-purple-600"
                />
              </div>

              {/* Guest List */}
              <div className="space-y-3">
                {filteredGuests.map((guest, index) => (
                  <motion.div
                    key={guest.id}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: index * 0.05 }}
                    className="bg-white rounded-2xl p-4 shadow-lg"
                  >
                    <div className="flex items-start justify-between mb-3">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-white font-bold">
                          {guest.name.charAt(0)}
                        </div>
                        <div>
                          <h4 className="font-bold text-gray-900">{guest.name}</h4>
                          <div className="flex items-center gap-2 mt-1">
                            {getStatusIcon(guest.status)}
                            <span className="text-xs text-gray-600 capitalize">{guest.status}</span>
                          </div>
                        </div>
                      </div>
                      <div className={`w-3 h-3 rounded-full ${getStatusColor(guest.status)}`} />
                    </div>

                    <div className="space-y-2 text-sm">
                      <div className="flex items-center gap-2 text-gray-600">
                        <Mail className="w-4 h-4" />
                        <span>{guest.email}</span>
                      </div>
                      <div className="flex items-center gap-2 text-gray-600">
                        <Phone className="w-4 h-4" />
                        <span>{guest.phone}</span>
                      </div>
                      {guest.companions > 0 && (
                        <div className="flex items-center gap-2 text-gray-600">
                          <Users className="w-4 h-4" />
                          <span>+{guest.companions} companion{guest.companions > 1 ? 's' : ''}</span>
                        </div>
                      )}
                    </div>

                    {guest.checkedIn && (
                      <div className="mt-3 pt-3 border-t border-gray-100">
                        <span className="inline-flex items-center gap-1.5 text-xs font-medium text-green-600 bg-green-50 px-2.5 py-1 rounded-full">
                          <CheckCircle className="w-3 h-3" />
                          Checked In
                        </span>
                      </div>
                    )}
                  </motion.div>
                ))}
              </div>
            </motion.div>
          )}

          {/* Details Tab */}
          {activeTab === 'details' && (
            <motion.div
              key="details"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              className="space-y-4"
            >
              {/* Package Info */}
              <div className="bg-white rounded-2xl p-5 shadow-lg">
                <h3 className="font-bold text-gray-900 mb-3">Package Details</h3>
                <div className="space-y-2 text-sm">
                  <p><span className="font-semibold text-gray-700">Package:</span> {event.package}</p>
                  <p><span className="font-semibold text-gray-700">Price:</span> ${event.packagePrice}</p>
                  <p><span className="font-semibold text-gray-700">Invitations:</span> {event.invitations}</p>
                </div>
              </div>

              {/* Template Info */}
              <div className="bg-white rounded-2xl p-5 shadow-lg">
                <h3 className="font-bold text-gray-900 mb-3">Invitation Template</h3>
                <p className="text-sm text-gray-600">{event.template}</p>
              </div>

              {/* Settings */}
              <div className="bg-white rounded-2xl p-5 shadow-lg">
                <h3 className="font-bold text-gray-900 mb-3">Event Settings</h3>
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-gray-700">Allow Companions</span>
                    <span className="text-sm font-semibold text-gray-900">{event.allowCompanions ? 'Yes' : 'No'}</span>
                  </div>
                  {event.allowCompanions && (
                    <div className="flex items-center justify-between">
                      <span className="text-sm text-gray-700">Max Companions</span>
                      <span className="text-sm font-semibold text-gray-900">{event.maxCompanions}</span>
                    </div>
                  )}
                </div>
              </div>

              {/* Description */}
              <div className="bg-white rounded-2xl p-5 shadow-lg">
                <h3 className="font-bold text-gray-900 mb-3">Description</h3>
                <p className="text-sm text-gray-600">{event.description}</p>
              </div>

              {/* Actions */}
              <div className="grid grid-cols-2 gap-3">
                <motion.button
                  whileTap={{ scale: 0.95 }}
                  className="flex items-center justify-center gap-2 bg-gradient-to-r from-purple-600 to-pink-600 text-white px-4 py-3 rounded-xl shadow-lg font-medium"
                >
                  <Edit className="w-4 h-4" />
                  Edit
                </motion.button>
                <motion.button
                  whileTap={{ scale: 0.95 }}
                  className="flex items-center justify-center gap-2 bg-red-600 text-white px-4 py-3 rounded-xl shadow-lg font-medium"
                >
                  <Trash2 className="w-4 h-4" />
                  Delete
                </motion.button>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}
